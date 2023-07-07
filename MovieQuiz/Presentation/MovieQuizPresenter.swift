//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Olga Vasileva on 06.07.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private var statisticService: StatisticService!
    private var questionFactory: QuestionFactory?
    private weak var viewController: MovieQuizViewController?
    private var alertPresenter: AlertPresenter?
    
    let questionsCount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        statisticService = StatisticServiceImpl()
        alertPresenter = AlertPresenterImpl(viewController: viewController)
    }
    
    func loadData() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didLoadDataFromServer(){
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error){
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion) {
        viewController?.hideLoadingIndicator()
        
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        self.viewController?.show(quiz: viewModel)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsCount - 1
        }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
        }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
        return questionStep
    }
    
    private func didAnswer(isYes: Bool){
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            showFinalResults()
        } else {
            self.switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        self.didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.showImageBorderAndDisableButtons(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.viewController?.hideImageBorderAndEnableButtons()
        }
    }
    
    func showFinalResults() {
        viewController?.hideLoadingIndicator()

        statisticService?.store(correct: correctAnswers, total: questionsCount)

        let alertModel = AlertModel(
            title: "Игра окончена",
            message: makeResultMassage(),
            buttonText: "OK",
            actionButton: { [weak self] in
                self?.resetQuestionIndex()
                self?.restartGame()
            }
        )

        alertPresenter?.show(alertModel: alertModel)
    }

    func makeResultMassage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error massage")
            return ""
        }
        
        let result = "Ваш результат: \(correctAnswers)/\(self.questionsCount)"
        let gamesCount = "Количество сыгранных квизов: \(statisticService.gameCount)"
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let totalAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMassage = [
            result, gamesCount, record, totalAccuracy
        ].joined(separator: "\n")
        
        return resultMassage
    }
    
}
