# frozen_string_literal: true

require 'casbin/management_enforcer'
require 'casbin/util'

module Casbin
  # Enforcer = ManagementEnforcer + RBAC_API + RBAC_WITH_DOMAIN_API
  #
  # creates an enforcer via file or DB.
  #  File:
  #    e = casbin.Enforcer("path/to/basic_model.conf", "path/to/basic_policy.csv")
  #  MySQL DB:
  #    a = mysqladapter.DBAdapter("mysql", "mysql_username:mysql_password@tcp(127.0.0.1:3306)/")
  #    e = casbin.Enforcer("path/to/basic_model.conf", a)
  class Enforcer < ManagementEnforcer
    # gets the roles that a user has.
    def get_roles_for_user(name)
      model.model['g']['g'].rm.get_roles(name)
    end

    # gets the users that has a role.
    def get_users_for_role(name)
      model.model['g']['g'].rm.get_users(name)
    end

    # determines whether a user has a role.
    def has_role_for_user(name, role)
      roles = get_roles_for_user(name)
      roles.include?(role)
    end

    # adds a role for a user.
    # Returns false if the user already has the role (aka not affected).
    def add_role_for_user(user, role)
      add_grouping_policy(user, role)
    end

    # deletes a role for a user.
    # Returns false if the user does not have the role (aka not affected).
    def delete_role_for_user(user, role)
      remove_grouping_policy(user, role)
    end

    # deletes all roles for a user.
    # Returns false if the user does not have any roles (aka not affected).
    def delete_roles_for_user(user)
      remove_filtered_grouping_policy(0, user)
    end

    # deletes a user.
    # Returns false if the user does not exist (aka not affected).
    def delete_user(user)
      res1 = remove_filtered_grouping_policy(0, user)
      res2 = remove_filtered_policy(0, user)
      res1 || res2
    end

    # deletes a role.
    # Returns false if the role does not exist (aka not affected).
    def delete_role(role)
      res1 = remove_filtered_grouping_policy(1, role)
      res2 = remove_filtered_policy(0, role)
      res1 || res2
    end

    # deletes a permission.
    # Returns false if the permission does not exist (aka not affected).
    def delete_permission(*permission)
      remove_filtered_policy(1, *permission)
    end

    # adds a permission for a user or role.
    # Returns false if the user or role already has the permission (aka not affected).
    def add_permission_for_user(user, *permission)
      add_policy(Util.join_slice(user, *permission))
    end

    # deletes a permission for a user or role.
    # Returns false if the user or role does not have the permission (aka not affected).
    def delete_permission_for_user(user, *permission)
      remove_policy(Util.join_slice(user, *permission))
    end

    # deletes permissions for a user or role.
    # Returns false if the user or role does not have any permissions (aka not affected).
    def delete_permissions_for_user(user)
      remove_filtered_policy(0, user)
    end

    # gets permissions for a user or role.
    def get_permissions_for_user(user)
      get_filtered_policy(0, user)
    end

    # determines whether a user has a permission.
    def has_permission_for_user(user, *permission)
      has_policy(Util.join_slice(user, *permission))
    end

    # gets implicit roles that a user has.
    # Compared to get_roles_for_user(), this function retrieves indirect roles besides direct roles.
    # For example:
    # g, alice, role:admin
    # g, role:admin, role:user
    # get_roles_for_user("alice") can only get: ["role:admin"].
    # But get_implicit_roles_for_user("alice") will get: ["role:admin", "role:user"].
    def get_implicit_roles_for_user(name, domain = nil)
      res = []
      queue = [name]
      while queue.size.positive?
        name = queue.delete_at(0)
        rm_map.each_value do |rm|
          rm.get_roles(name, domain).each do |r|
            res << r
            queue << r
          end
        end
      end

      res
    end

    # gets implicit permissions for a user or role.
    # Compared to get_permissions_for_user(), this function retrieves permissions for inherited roles.
    # For example:
    # p, admin, data1, read
    # p, alice, data2, read
    # g, alice, admin
    # get_permissions_for_user("alice") can only get: [["alice", "data2", "read"]].
    # But get_implicit_permissions_for_user("alice") will get: [["admin", "data1", "read"], ["alice", "data2", "read"]].
    def get_implicit_permissions_for_user(user, domain = nil)
      roles = get_implicit_roles_for_user(user, domain)
      roles.insert(0, user)
      res = []
      roles.each do |role|
        permissions = if domain
                        get_permissions_for_user_in_domain(role, domain)
                      else
                        get_permissions_for_user(role)
                      end

        res.concat(permissions)
      end

      res
    end

    # gets implicit users for a permission.
    # For example:
    # p, admin, data1, read
    # p, bob, data1, read
    # g, alice, admin
    # get_implicit_users_for_permission("data1", "read") will get: ["alice", "bob"].
    # Note: only users will be returned, roles (2nd arg in "g") will be excluded.
    def get_implicit_users_for_permission(*permission)
      subjects = get_all_subjects
      roles = get_all_roles
      users = Util.set_subtract(subjects, roles)
      users.find_all { |user| enforce(*Util.join_slice(user, *permission)) }
    end

    # gets the roles that a user has inside a domain.
    def get_roles_for_user_in_domain(name, domain)
      model.model['g']['g'].rm.get_roles(name, domain)
    end

    # gets the users that has a role inside a domain.
    def get_users_for_role_in_domain(name, domain)
      model.model['g']['g'].rm.get_users(name, domain)
    end

    # adds a role for a user inside a domain.
    # Returns false if the user already has the role (aka not affected).
    def add_role_for_user_in_domain(user, role, domain)
      add_grouping_policy(user, role, domain)
    end

    # deletes a role for a user inside a domain.
    # Returns false if the user does not have any roles (aka not affected).
    def delete_roles_for_user_in_domain(user, role, domain)
      remove_filtered_grouping_policy(0, user, role, domain)
    end

    # gets permissions for a user or role inside domain.
    def get_permissions_for_user_in_domain(user, domain)
      get_filtered_policy(0, user, domain)
    end
  end
end
