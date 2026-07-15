import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuestion = questions[currentQuestionIndex]
        let quizStepViewModel = convert(model: currentQuestion)
        show(quiz: quizStepViewModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(image: UIImage(named: model.image) ?? UIImage(),
              question: model.text,
              questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        previewImageView.image = step.image
        questionTitleLabel.text = step.question
        indexLabel.text = step.questionNumber
        
        previewImageView.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                let firstQuestion = self.questions[self.currentQuestionIndex]
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.borderWidth = 8
        previewImageView.layer.cornerRadius = 20
        previewImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
}
