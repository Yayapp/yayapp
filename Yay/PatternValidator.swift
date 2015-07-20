

/**
 * Created by Ners on 24.06.2015.
 */
struct PatternValidator {

    static let EMAIL_PATTERN:String = "^[-a-z0-9!#$%&'*+/=?^_`{|}~]+(?:\\.[-a-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\\.)*(?:aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|[a-z][a-z])$";


    static func validate(str:String!, patternString:String!)->Bool{
        if str.rangeOfString(patternString, options: .RegularExpressionSearch) != nil{
            return true
        } else {
            return false
        }
    }
}
