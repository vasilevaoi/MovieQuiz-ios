import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var textLabel: UILabel!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?

    // MARK: - Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenterImpl()
   
        presenter = MovieQuizPresenter(viewController: self)
                
        noButton.layer.masksToBounds=true
        noButton.layer.cornerRadius = 15
        yesButton.layer.masksToBounds=true
        yesButton.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func showLoadingIndicator(){
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        
    }
    
    func showImageBorderAndDisableButtons(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func hideImageBorderAndEnableButtons(){
        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func showNetworkError(message: String){
        showLoadingIndicator()
        
        let alertModel = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
            
        let action = UIAlertAction(
            title: "Попробовать ещё раз",
            style: .default) { [weak self] _ in
                guard let self = self else { return }

                self.presenter.restartGame()
            }
        
        alertModel.addAction(action)

        self.present(alertModel, animated: true, completion: nil)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.white.cgColor
    }
}
