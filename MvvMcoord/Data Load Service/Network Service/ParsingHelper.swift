import Foundation
import SwiftyJSON
import FirebaseFunctions


class ParsingHelper {

    public static func parseJsonObjArr<T: ModelProtocol>(result: HTTPSCallableResult?, key:String)->[T]{
        var res: [T] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let t: T = T(json: j)
                res.append(t)
            }
        }
        return res
    }
    
    public static func parseCatalogModel(result: HTTPSCallableResult?, key:String)->[CatalogModel]{
        var res: [CatalogModel] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let t = CatalogModel(json: j)
                res.append(t)
            }
        }
        return res
    }
    
    public static func parseCatalogModel1(result: HTTPSCallableResult?, key:String)->[CatalogModel1]{
        var res: [CatalogModel1] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let t = CatalogModel1(json: j)
                res.append(t)
            }
        }
        return res
    }
    
    public static func parseUUIDModel(result: HTTPSCallableResult?, key:String)->[UidModel]{
        var res: [UidModel] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let t = UidModel(json: j)
                res.append(t)
            }
        }
        return res
    }
    

    public static func parseJsonArr(result: HTTPSCallableResult?, key:String)->[Int]{
        var res: [Int] = []
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                res.append(j.intValue)
            }
        }
        return res
    }

   
    

    public static func parseJsonDict(result: HTTPSCallableResult?, key:String)->[Int:Int]{
        var res: [Int:Int] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let dict = j.dictionaryObject as! [String:Int]
                for(key,val) in dict {
                    res[Int(key)!] = val
                }
            }
        }
        return res
    }
    
    public static func parseJsonDict2(result: HTTPSCallableResult?, key:String)->[Int:String]{
        var res: [Int:String] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let dict = j.dictionaryObject as! [String:String]
                for(key,val) in dict {
                    res[Int(key)!] = val
                }
            }
        }
        return res
    }
    
    
    public static func parseJsonDictWithValArr(result: HTTPSCallableResult?, key:String)->[Int:[Int]]{
        var res: [Int:[Int]] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].dictionaryValue {
                guard let k = Int(j.key) else {continue}
                for v in j.value {
                    let num = v.1.intValue
                    if res[k] == nil {
                        res[k] = []
                    }
                    res[k]?.append(num)
                }
               
            }
        }
        return res
    }

    public static func parseJsonVal<T>(type: T.Type, result: HTTPSCallableResult?, key:String)->T?{
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            switch type {
            case is Int.Type:
                return json[key].intValue as? T
            case is CGFloat.Type:
                return json[key].floatValue as? T
            case is String.Type:
                return json[key].stringValue as? T
            default:
                return json[key].stringValue as? T
            }
        }
        return nil
    }
    
    public static func parseJsonDictWithValArr<T>(type: T.Type, result: HTTPSCallableResult?, key:String)->[Int:[T]]{
        var res: [Int:[T]] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].dictionaryValue {
                guard let k = Int(j.key) else {continue}
                for v in j.value {
                    var val : T
                    switch type {
                    case is Int.Type:
                        val = v.1.intValue as! T
                    case is CGFloat.Type:
                        val = v.1.floatValue as! T
                    case is String.Type:
                        val = v.1.stringValue as! T
                    default:
                        val = v.1.stringValue as! T
                    }
                    if res[k] == nil {
                        res[k] = []
                    }
                    res[k]?.append(val)
                }
            }
        }
        return res
    }
    
    
    public static func parseJsonDict<T>(type: T.Type, result: HTTPSCallableResult?, key:String)->[Int:T]{
        var res: [Int:T] = [:]
        if let text = (result?.data as? [String: Any])?[key] as? String,
            let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            for j in json["items"].arrayValue {
                let dict = j.dictionaryObject as! [String:T]
                for(key,v) in dict {
                    res[Int(key)!] = v
                }
            }
        }
        return res
    }

}
