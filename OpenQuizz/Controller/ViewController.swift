//
//  ViewController.swift
//  OpenQuizz
//
//  Created by ALEXANDRE GROSSON on 17/10/2018.
//  Copyright © 2018 GROSSON. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var newGameButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var questionView: QuestionView!
    
    var game = Game()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(rawValue: "QuestionsLoaded")
        NotificationCenter.default.addObserver(self, selector: #selector(questionsLoaded), name: name, object: nil)
        
        startNewGame()
        /* 1. je crée un objet de type UIPanGestureRecognizer
         a. Paramètre target: self car c'est le controlleur qui détecte
         b. action : un fonction que l'on crée et qui va déterminer l'action associée au mouvement
         2. J'ajoute cet objet à la vue qui doit detecter le mouvement : ici questionView
         
         */
        let  panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragQuestionView(_:)))
        questionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func dragQuestionView(_ sender: UIPanGestureRecognizer) {
        if game.state == .ongoing {
            switch sender.state {
            case .began, .changed:
                transformQestionViewWith(gesture: sender)
            case .ended, .cancelled:
                answerQuestion()
            default:
                break
            }
        }
    }
    
    private func transformQestionViewWith(gesture : UIPanGestureRecognizer){
        // On récupère le CGPoint du mouvement consécutif au geste
        let translation = gesture.translation(in: questionView)
        // on utilise ces coordonnées x et y pour modifier/bouger la translation
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        // je définis la largeur de l'écran principal
        let screenWidth = UIScreen.main.bounds.width
        // Je définis le pourcentage de translation par rapport au milieu de l'écran
        let translationpercent = translation.x/(screenWidth/2)
        // J'applique le % de translation au niveau de rotation que je souhaite
        let rotationAngle = (CGFloat.pi/6)*translationpercent
        // j'utilise cet angle pour créer une rotation
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        // je crée une trnasformation globale en concaténant translation et rotation
        let transform = translationTransform.concatenating(rotationTransform)
        // j'applique cette transformation à la vue
        questionView.transform = transform
        
        if translation.x >  0 {
            questionView.style = .correct
        }
        else {
            questionView.style = .incorrect
        }
    }
    
    private func answerQuestion(){
        // cela permet de répondre à la question quand on arrête le geste en focntion ddu style de la vue
        switch questionView.style {
        case .correct:
            game.answerCurrentQuestion(with: true)
        case .incorrect:
            game.answerCurrentQuestion(with: false)
        case .standard:
            break
        }
        // mise à jour score
        scoreLabel.text = "\(game.score) / 10"
        
        
        /*
         Objectif: glisser la vue hors de l'écran:
         1. on obtient la largeur de l'écran
         2. on crée un transformation que l'on animera
         3. en focntion de la réponse la translation est vers la droite ou la gauche
         4. On crée une animation sur la translation avec UIView.animate
         */
        
        let widthScreen = UIScreen.main.bounds.width
        let translationTransform: CGAffineTransform
        if questionView.style == .correct {
            translationTransform = CGAffineTransform(translationX: widthScreen, y: 0)
        } else {
            translationTransform = CGAffineTransform(translationX: -widthScreen, y: 0)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.questionView.transform = translationTransform
        }) { (success) in
            if success {
                self.showQuestionView()
            }
        }
    }
    
    private func showQuestionView(){
        // on remet la vue à sa place
        questionView.transform = .identity
        // on reduit l'image
        questionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        // on remet le style standard
        questionView.style = .standard
        
        // on regarde si le jeu est terminé
        switch game.state {
        case .ongoing:
            questionView.title = game.currentQuestion.title
        case .over:
            questionView.title = "Game Over"
        }
       
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.questionView.transform = .identity
        }, completion: nil)
     
        
    }
    
    /*
     */
    
    @objc func questionsLoaded() {
        activityIndicator.isHidden = true
        newGameButton.isHidden = false
        questionView.title = game.currentQuestion.title
        
    }
    
    @IBAction func didTapNewGameButton() {
        startNewGame()
    }
    
    private func startNewGame(){
        newGameButton.isHidden = true
        activityIndicator.isHidden = false
        scoreLabel.text = "0 / 10"
        questionView.title = "Loading..."
        questionView.style = .standard
        game.refresh()
    }
}

