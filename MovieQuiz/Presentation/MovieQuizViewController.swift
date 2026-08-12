import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var previewImageView: UIImageView?
    @IBOutlet private weak var questionTitleLabel: UILabel?
    @IBOutlet private weak var indexLabel: UILabel?
    @IBOutlet private weak var noButton: UIButton?
    @IBOutlet private weak var yesButton: UIButton?
    
    // MARK: - Private Properties
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDependencies()
    }

    private func configureDependencies() {
        statisticService = StatisticService()

        let factory = QuestionFactory()
        factory.setup(delegate: self)

        questionFactory = factory
        factory.requestNextQuestion()
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(answer: false)
        
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(answer: true)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(image: UIImage(named: model.image) ?? UIImage(),
              question: model.text,
              questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        noButton?.isEnabled = true
        yesButton?.isEnabled = true
        previewImageView?.image = step.image
        questionTitleLabel?.text = step.question
        indexLabel?.text = step.questionNumber
        
        previewImageView?.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        guard let statisticService = statisticService else {
            return
        }
        
        let bestGame = statisticService.bestGame
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return}
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func showAnswerResult(answer: Bool) {
        guard let currentQuestion else { return }

            let isCorrect = answer == currentQuestion.correctAnswer

        noButton?.isEnabled = false
        yesButton?.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        previewImageView?.layer.masksToBounds = true
        previewImageView?.layer.borderWidth = 8
        previewImageView?.layer.cornerRadius = 20
        previewImageView?.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(
                correct: correctAnswers,
                total: questionsAmount
            )
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
}
