//
//  UserAdminController.swift
//  FeatherCMS
//
//  Created by Tibor Bodecs on 2020. 03. 23..
//

import Vapor
import Fluent
import ViperKit
import ViewKit

final class UserAdminController: ViperAdminViewController {

    typealias Module = UserModule
    typealias Model = UserModel
    typealias EditForm = UserEditForm

    var listSortable: [FieldKey] {
        [
            Model.FieldKeys.email,
        ]
    }

    func search(using qb: QueryBuilder<Model>, for searchTerm: String) {
        qb.filter(\.$email ~~ searchTerm)
    }

    func listBuilder(req: Request, queryBuilder: QueryBuilder<Model>) throws -> QueryBuilder<Model> {
        queryBuilder.sort(\Model.$email)
    }
    
    func delete(req: Request) throws -> EventLoopFuture<String> {
        try self.find(req).flatMap { user in
            UserTokenModel
                .query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .delete()
        }
        .throwingFlatMap { try self.find(req) }
        .flatMap { item in item.delete(on: req.db)
        .map { item.id!.uuidString } }
    }
}

