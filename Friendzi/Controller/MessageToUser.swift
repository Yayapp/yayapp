
/**
 * Created by Developer on 29.05.2014.
 */

//TODO:- Move it to extension
final class MessageToUser {
    static func showMessage(title:String, textId:String!) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = textId
        alert.addButtonWithTitle("OK".localized)
        alert.show()
    }

    static func showDefaultErrorMessage(textId:String!) {
        let alert = UIAlertView()
        alert.title = "Ooops".localized
        alert.message = textId
        alert.addButtonWithTitle("OK".localized)
        alert.show()
    }

    static func showDefaultErrorMessage(textId:String!, delegate:UIAlertViewDelegate) {
        let alert = UIAlertView()
        alert.title = "Ooops".localized
        alert.message = textId
        alert.addButtonWithTitle("OK".localized)
        alert.delegate = delegate
        alert.show()
    }
}
