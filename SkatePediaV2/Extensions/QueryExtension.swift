//
//  QueryExtension.swift
//  SkatePediaV2
//
//  Created by Brayden Strivens on 12/11/24.
//

import Foundation
import FirebaseFirestore
import Combine

extension Query {
    
    /// Fetches the documents from a collection and converts them to an array of objects of any type.
    ///
    /// - Returns: An array of objects of any type that contain data from the database.
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).item
    }
    
    /// Fetches a single document from a collection and converts to an object of any type.
    ///
    /// - Returns: An object of any type containing the data from the database.
    func getDocument<T>(as type: T.Type) async throws -> T where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let decodedData = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return decodedData[0]
    }
    
    /// Fetches documents from a collection and converts to on object of any type. Also saves the last fetched document.
    ///
    /// - Returns: A tuple containing an array of objects fetched from the database and the last fetched document.
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (
        item: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
            let snapshot = try await self.getDocuments()
            
            let items = try snapshot.documents.map({ document in
                try document.data(as: T.self)
            })
            
            return (items, snapshot.documents.last)
    }
    
    /// Starts fetching documents from a collection after the last document.
    ///
    /// - Parameters:
    ///  - lastDocument: The last fetched document from a collection.
    ///
    ///  - Returns: A query object.
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        
        return self
            .start(afterDocument: lastDocument)
    }
    
    /// Counts the number of documents in a collection
    ///
    /// - Returns: The number of documents in a collection as an 'Integer'.
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG1: LISTENER FOUND NO DOCUMENTS")
                return
            }
            
            let data: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            publisher.send(data)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
    /// Adds a listener to a collection that allows for live updating when the collection is updated.
    ///
    /// - Parameters:
    ///  - type: The object type to encode the collection's documents to.
    func addSnapshotListenerToCollection<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG1: LISTENER FOUND NO DOCUMENTS")
                return
            }
            
            let data: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            publisher.send(data)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
}
