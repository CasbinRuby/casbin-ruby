# frozen_string_literal: true

module Casbin
  module Rbac
    module DefaultRoleManager
      # represents the data structure for a role in RBAC.
      class Role
        attr_accessor :name, :roles

        def initialize(name)
          @name = name
          @roles = []
        end

        def add_role(role)
          return if roles.any? { |rr| rr.name == role.name }

          roles << role
        end

        def delete_role(role)
          roles.delete_if { |rr| rr.name == role.name }
        end

        def has_role(role_name, hierarchy_level)
          return true if role_name == name
          return false if hierarchy_level.to_i <= 0

          roles.each { |role| return true if role.has_role(role_name, hierarchy_level - 1) }
          false
        end

        def get_roles
          roles.map(&:name)
        end

        def has_direct_role(name)
          roles.any? { |role| role.name == name }
        end

        def to_string
          return if roles.empty?

          names = get_roles.join(', ')
          if roles.size == 1
            "#{name} < #{names}"
          else
            "#{name} < (#{names})"
          end
        end
      end
    end
  end
end
