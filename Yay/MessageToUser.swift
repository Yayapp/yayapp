
/**
 * Created by Developer on 29.05.2014.
 */
class MessageToUser {

    static func showMessage(title:String, textId:String!) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = textId
        alert.addButtonWithTitle("OK")
        alert.show()
    }

    static func showDefaultErrorMessage(textId:String!) {
        let alert = UIAlertView()
        alert.title = "Ooops"
        alert.message = textId
        alert.addButtonWithTitle("OK")
        alert.show()
    }

}
