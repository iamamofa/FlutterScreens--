//
//  HomeViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    private let firebaseStorageManager = FirebaseStorageManager()
    
    @Published var posts: [Post]?
    @Published var postsAuthorsProfilePicturesURLs: [String: URL] = [:]
    @Published var postsPicturesURLs: [String: URL] = [:]
    @Published var postsComments: [String: [Comment]] = [:]
    @Published var postsCommentsAuthorsProfilePicturesURLs: [String: URL] = [:]
    
    @Published var usersData: [String: [String]] = [:]
    @Published var usersProfilePicturesURLs: [String: URL] = [:]
    
    init(forPreviews: Bool) {

        let commentsPost1: [Comment] = [Comment(authorID: "2", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "3", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost2: [Comment] = [Comment(authorID: "3", postID: "2", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "1", postID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        let commentsPost3: [Comment] = [Comment(authorID: "1", postID: "3", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "2", postID: "3", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]

        self.posts = [Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost1),
                      Post(id: "1", authorID: "2", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", addDate: Date(), text: "Good form for now!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost2),
                      Post(id: "1", authorID: "3", authorFirstName: "Jakub", authorUsername: "jakub23.d", authorProfilePictureURL: "", addDate: Date(), text: " Hell Yeeeah!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: commentsPost3)]
        
        self.postsComments = ["1": commentsPost1, "2": commentsPost2, "3": commentsPost3]
        
        self.usersData = ["id1": ["jan", "jan23.d"], "id2": ["maciej", "maciej23.d"], "id3": ["jakub", "jakub23.d"]]
        
    }
    
    init() {
        fetchData()
    }
    
    func setup(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
    
    func fetchData() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.fetchPosts(userID: self.sessionStore.currentUser!.uid) { fetchedPosts, success in
                if success {
                    if let fetchedPosts = fetchedPosts {
                        self.posts = fetchedPosts
                        for post in self.posts! {
                            self.firebaseStorageManager.getDownloadURLForImage(stringURL: post.authorProfilePictureURL, userID: post.authorID) { photoURL, success in
                                if success {
                                    if let photoURL = photoURL {
                                        self.postsAuthorsProfilePicturesURLs.updateValue(photoURL, forKey: post.id)
                                    }
                                }
                            }
                            
                            if let postPhotoURL = post.photoURL {
                                self.firebaseStorageManager.getDownloadURLForPostImage(stringURL: postPhotoURL, userID: post.authorID, postID: post.id) { photoURL, success in
                                    if success {
                                        if let photoURL = photoURL {
                                            self.postsPicturesURLs.updateValue(photoURL, forKey: post.id)
                                        }
                                    }
                                }
                            }
                            
                            self.firestoreManager.fetchComments(postID: post.id) { comments, success in
                                if success {
                                    if let fetchedComments = comments {
                                        self.postsComments.updateValue(fetchedComments, forKey: post.id)
                                        for comment in fetchedComments {
                                            if self.postsCommentsAuthorsProfilePicturesURLs[comment.authorID] == nil {
                                                self.firebaseStorageManager.getDownloadURLForImage(stringURL: comment.authorProfilePictureURL, userID: comment.authorID) { photoURL, success in
                                                    if success {
                                                        if let photoURL = photoURL {
                                                            self.postsCommentsAuthorsProfilePicturesURLs.updateValue(photoURL, forKey: comment.authorID)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadPostPhoto(image: UIImage, userID: String, postID: String, completion: @escaping ((String?, Bool) -> ())) {
        self.firebaseStorageManager.uploadPostImageToStorage(image: image, userID: userID, postID: postID) { photoURL, success in
            if success {
                if let photoURL = photoURL {
                    self.firestoreManager.addPostPictureURLToPostsData(photoURL: photoURL, postID: postID) { success in
                        completion(photoURL, success)
                    }
                } else {
                    completion(nil, false)
                }
            } else {
                completion(nil, false)
            }
        }
    }
    
    func deletePostPhoto(photoURL: String, userID: String, postID: String, completion: @escaping ((Bool) -> ())) {
        self.firebaseStorageManager.deletePostImageFromStorage(photoURL: photoURL, userID: userID, postID: postID) { success in
            if success {
                self.firestoreManager.deletePostPictureURLFromPostsData(postID: postID) { success in
                    completion(success)
                }
            } else {
                completion(success)
            }
        }
    }
    
    func addPost(authorID: String, authorFirstName: String, authorUsername: String, authorProfilePictureURL: String, text: String, photo: UIImage? = nil, completion: @escaping ((Bool) -> ())) {
        let postID = UUID().uuidString
        if let photo = photo {
            self.uploadPostPhoto(image: photo, userID: authorID, postID: postID) { photoURL, success in
                if success {
                    if let photoURL = photoURL {
                        self.firestoreManager.postDataCreation(id: postID, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil, comments: nil, photoURL: photoURL) { success in
                            completion(success)
                        }
                    }
                } else {
                    self.firestoreManager.postDataCreation(id: postID, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil, comments: nil, photoURL: nil) { success in
                        completion(success)
                    }
                }
            }
        } else {
            self.firestoreManager.postDataCreation(id: postID, authorID: authorID, authorFirstName: authorFirstName, authorUsername: authorUsername, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil, comments: nil, photoURL: nil) { success in
                completion(success)
            }
        }
    }
    
    func editPost(postID: String, userID: String, text: String, photo: UIImage?, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            if let photo = photo {
                self.uploadPostPhoto(image: photo, userID: userID, postID: postID) { photoURL, success in
                    if success {
                        if let photoURL = photoURL {
                            self.firestoreManager.postEdit(id: postID, text: text, photoURL: photoURL) { success in
                                completion(success)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                self.firestoreManager.postEdit(id: postID, text: text) { success in
                    completion(success)
                }
            }
        }
    }
    
    func removePostPhotoURLAfterDeletion(postID: String) {
        self.postsPicturesURLs.removeValue(forKey: postID)
    }
    
    func getCurrentPostDetails(postID: String) -> Post? {
        if let posts = self.posts {
            for post in posts {
                if post.id == postID {
                    return post
                }
            }
        } else {
            return nil
        }
        return nil
    }
    
    func reactToPost(postID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.postAddReaction(postID: postID, userIDThatReacted: self.sessionStore.currentUser!.uid) { success in
                if success {
                    self.firestoreManager.addPostIDToPostsReactedByUser(userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                        completion(success)
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func removeReactionFromPost(postID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.postRemoveReaction(postID: postID, userIDThatRemovedReaction: self.sessionStore.currentUser!.uid) { success in
                if success {
                    self.firestoreManager.removePostIDFromPostsReactedByUser(userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                        completion(success)
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func deletePost(postID: String, postPictureURL: String? = nil, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.postRemoval(id: postID) { success in
                if let postPictureURL = postPictureURL {
                    self.firebaseStorageManager.deletePostImageFromStorage(photoURL: postPictureURL, userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                        self.firestoreManager.removePostIDFromPostsReactedByUser(userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                            if success {
                                self.firestoreManager.removePostIDFromPostsCommentedByUser(userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                                    if success {
                                        if let postComments = self.postsComments[postID] {
                                            for comment in postComments {
                                                self.deleteComment(postID: postID, commentID: comment.id) { success in
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }
    
    func commentPost(postID: String, authorID: String, authorFirstName: String, authorLastName: String, authorProfilePictureURL: String, text: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentDataCreation(id: UUID().uuidString, authorID: authorID, postID: postID, authorFirstName: authorFirstName, authorUsername: authorLastName, authorProfilePictureURL: authorProfilePictureURL, addDate: Date(), text: text, reactionsUsersIDs: nil) { success in
                if success {
                    self.firestoreManager.addPostIDToPostsCommentedByUser(userID: self.sessionStore.currentUser!.uid, postID: postID) { success in
                        if success {
                            self.firestoreManager.postAddCommentingUserID(postID: postID, userIDThatCommented: authorID) { success in
                                completion(success)
                            }
                        } else {
                            completion(success)
                        }
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func editComment(commentID: String, text: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentEdit(id: commentID, text: text) { success in
                if success {
                }
                completion(success)
            }
        }
    }
    
    func reactToComment(userID: String, commentID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentAddReaction(commentID: commentID, userIDThatReacted: userID) { success in
                if success {
                    self.firestoreManager.addCommentIDToCommentsReactedByUser(userID: userID, commentID: commentID) { success in
                        completion(success)
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func removeReactionFromComment(userID: String, commentID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentRemoveReaction(commentID: commentID, userIDThatRemovedReaction: userID) { success in
                if success {
                    self.firestoreManager.removeCommentIDFromCommentsReactedByUser(userID: userID, commentID: commentID) { success in
                        completion(success)
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func deleteComment(postID: String, commentID: String, completion: @escaping ((Bool) -> ())) {
        if sessionStore.currentUser != nil {
            self.firestoreManager.commentRemoval(id: commentID) { success in
                if success {
                    self.firestoreManager.checkForMultipleCommentsOfSameUserToSamePost(postID: postID, userID: self.sessionStore.currentUser!.uid) { multipleCommentsExists in
                        if !multipleCommentsExists {
                            self.firestoreManager.postRemoveCommentingUserID(postID: postID, userIDThatRemovedComment: self.sessionStore.currentUser!.uid) { success in
                                if success {
                                    self.firestoreManager.removeCommentIDFromCommentsReactedByUser(userID: self.sessionStore.currentUser!.uid, commentID: postID) { success in
                                        completion(success)
                                    }
                                } else {
                                    completion(success)
                                }
                            }
                        } else {
                            self.firestoreManager.removeCommentIDFromCommentsReactedByUser(userID: self.sessionStore.currentUser!.uid, commentID: postID) { success in
                                completion(success)
                            }
                        }
                    }
                } else {
                    completion(success)
                }
            }
        }
    }
    
    func getPostAuthorProfilePictureURL(authorID: String, stringPhotoURL: String, completion: @escaping ((URL?) -> ())) {
        self.firebaseStorageManager.getDownloadURLForImage(stringURL: stringPhotoURL, userID: authorID) { photoURL, success in
            if success {
                completion(photoURL)
            }
        }
    }
    
    func getAllUsersData() {
        if sessionStore.currentUser != nil {
            self.firestoreManager.getAllUsersIDs(userID: self.sessionStore.currentUser!.uid) { usersIDs, success in
                if success {
                    if let usersIDs = usersIDs {
                        for userID in usersIDs {
                            self.firestoreManager.getAllUsersData(userID: userID) { userData, success in
                                if success {
                                    if let userData = userData {
                                        self.usersData.updateValue(userData, forKey: userID)
                                        
                                        if userData[2] != "" {
                                            self.firebaseStorageManager.getDownloadURLForImage(stringURL: userData[2], userID: userID) { photoDownloadURL, success in
                                                if success {
                                                    if let photoDownloadURL = photoDownloadURL {
                                                        self.usersProfilePicturesURLs.updateValue(photoDownloadURL, forKey: userID)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
