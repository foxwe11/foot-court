//
//  PlaceModel.swift
//  Foot court
//
//  Created by Admin on 05/11/2019.
//  Copyright © 2019 Anton Varenik. All rights reserved.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    

    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]


    static func getPlaces() -> [Place] {
    

        var places = [Place]()
    
        for place in restaurantNames {
        places.append(Place(name: place, location: "Minsk", type: "Kafe",
                            image: nil,  restaurantImage: place))
            }
        
        return places
        }
}
