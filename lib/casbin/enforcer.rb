# frozen_string_literal: true

module Casbin
  # Enforcer = ManagementEnforcer + RBAC_API + RBAC_WITH_DOMAIN_API
  #
  # creates an enforcer via file or DB.
  #  File:
  #    e = casbin.Enforcer("path/to/basic_model.conf", "path/to/basic_policy.csv")
  #  MySQL DB:
  #    a = mysqladapter.DBAdapter("mysql", "mysql_username:mysql_password@tcp(127.0.0.1:3306)/")
  #    e = casbin.Enforcer("path/to/basic_model.conf", a)
  class Enforcer < Casbin::ManagementEnforcer
    # gets the roles that a user has.
    def get_roles_for_user(name)
      # stub method
      puts "call get_roles_for_user with name = #{name}"
    end

    # gets the users that has a role.
    def get_users_for_role(name)
      # stub method
      puts "call get_users_for_role with name = #{name}"
    end

    # determines whether a user has a role.
    def has_role_for_user(name, role)
      # stub method
      puts "call has_role_for_user with name = #{name} role = #{role}"
    end

    # adds a role for a user.
    # Returns false if the user already has the role (aka not affected).
    def add_role_for_user(name, role)
      # stub method
      puts "call add_role_for_user with name = #{name} role = #{role}"
    end

    # deletes a role for a user.
    # Returns false if the user does not have the role (aka not affected).
    def delete_role_for_user(name, role)
      # stub method
      puts "call delete_role_for_user with name = #{name} role = #{role}"
    end

    # deletes all roles for a user.
    # Returns false if the user does not have any roles (aka not affected).
    def delete_roles_for_user(user)
      # stub method
      puts "call delete_roles_for_user with user = #{user}"
    end

    # deletes a user.
    # Returns false if the user does not exist (aka not affected).
    def delete_user(user)
      # stub method
      puts "call delete_user with user = #{user}"
    end

    # deletes a role.
    # Returns false if the role does not exist (aka not affected).
    def delete_role(role)
      # stub method
      puts "call delete_role with role = #{role}"
    end

    # deletes a permission.
    # Returns false if the permission does not exist (aka not affected).
    def delete_permission(*permission)
      # stub method
      puts "call delete_permission with permission = #{permission}"
    end

    # adds a permission for a user or role.
    # Returns false if the user or role already has the permission (aka not affected).
    def add_permission_for_user(user, *permission)
      # stub method
      puts "call add_permission_for_user with user = #{user} permission = #{permission}"
    end

    # deletes a permission for a user or role.
    # Returns false if the user or role does not have the permission (aka not affected).
    def delete_permission_for_user(user, *permission)
      # stub method
      puts "call delete_permission_for_user with user = #{user} permission = #{permission}"
    end

    # deletes permissions for a user or role.
    # Returns false if the user or role does not have any permissions (aka not affected).
    def delete_permissions_for_user(user)
      # stub method
      puts "call delete_permissions_for_user with user = #{user}"
    end

    # gets permissions for a user or role.
    def get_permissions_for_user(user)
      # stub method
      puts "call get_permissions_for_user with user = #{user}"
    end

    # determines whether a user has a permission.
    def has_permission_for_user(user, *permission)
      # stub method
      puts "call has_permission_for_user with user = #{user} permission = #{permission}"
    end

    # gets implicit roles that a user has.
    # Compared to get_roles_for_user(), this function retrieves indirect roles besides direct roles.
    # For example:
    # g, alice, role:admin
    # g, role:admin, role:user
    # get_roles_for_user("alice") can only get: ["role:admin"].
    # But get_implicit_roles_for_user("alice") will get: ["role:admin", "role:user"].
    def get_implicit_roles_for_user(name, *domain)
      # stub method
      puts "call get_implicit_roles_for_user with name = #{name} domain = #{domain}"
    end

    # gets the roles that a user has inside a domain.
    def get_roles_for_user_in_domain(name, domain)
      # stub method
      puts "call get_roles_for_user_in_domain with name = #{name} domain = #{domain}"
    end

    # gets implicit permissions for a user or role.
    # Compared to get_permissions_for_user(), this function retrieves permissions for inherited roles.
    # For example:
    # p, admin, data1, read
    # p, alice, data2, read
    # g, alice, admin
    # get_permissions_for_user("alice") can only get: [["alice", "data2", "read"]].
    # But get_implicit_permissions_for_user("alice") will get: [["admin", "data1", "read"], ["alice", "data2", "read"]].
    def get_implicit_permissions_for_user(user, *domain)
      # stub method
      puts "call get_implicit_permissions_for_user with user = #{user} domain = #{domain}"
    end

    # gets the users that has a role inside a domain.
    def get_users_for_role_in_domain(name, domain)
      # stub method
      puts "call get_users_for_role_in_domain with name = #{name} domain = #{domain}"
    end

    # deletes a role for a user inside a domain.
    # Returns false if the user does not have any roles (aka not affected).
    def delete_roles_for_user_in_domain(user, role, domain)
      # stub method
      puts "call delete_roles_for_user_in_domain with user = #{user} role = #{role} domain = #{domain}"
    end

    # adds a role for a user inside a domain.
    # Returns false if the user already has the role (aka not affected).
    def add_role_for_user_in_domain(user, role, domain)
      # stub method
      puts "call add_role_for_user_in_domain with user = #{user} role = #{role} domain = #{domain}"
    end

    # gets implicit users for a permission.
    # For example:
    # p, admin, data1, read
    # p, bob, data1, read
    # g, alice, admin
    # get_implicit_users_for_permission("data1", "read") will get: ["alice", "bob"].
    # Note: only users will be returned, roles (2nd arg in "g") will be excluded.
    def get_implicit_users_for_permission(*permission)
      # stub method
      puts "call get_implicit_users_for_permission with permission = #{permission}"
    end
  end
end
