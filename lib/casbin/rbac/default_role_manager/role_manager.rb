# frozen_string_literal: true

require 'logger'
require 'casbin/rbac/role_manager'
require 'casbin/rbac/default_role_manager/role'

module Casbin
  module Rbac
    module DefaultRoleManager
      # provides a default implementation for the RoleManager interface
      class RoleManager < Casbin::Rbac::RoleManager
        attr_accessor :all_roles, :max_hierarchy_level, :matching_func
        attr_reader :logger

        def initialize(max_hierarchy_level, logger: Logger.new($stdout))
          super()
          @logger = logger
          @all_roles = {}
          @max_hierarchy_level = max_hierarchy_level
        end

        def add_matching_func(fn)
          @matching_func = fn
        end

        def has_role(name)
          return all_roles.key?(name) if matching_func.nil?

          all_roles.each_key { |key| return true if matching_func.call(name, key) }
          false
        end

        def create_role(name)
          all_roles[name] = Role.new(name) unless all_roles.key?(name)
          if matching_func
            all_roles.each do |key, role|
              all_roles[name].add_role(role) if matching_func.call(name, key) && name != key
            end
          end

          all_roles[name]
        end

        def clear
          @all_roles = {}
        end

        def add_link(name1, name2, *domain)
          names = names_by_domain(name1, name2, *domain)

          role1 = create_role(names[0])
          role2 = create_role(names[1])
          role1.add_role(role2)
        end

        def delete_link(name1, name2, *domain)
          names = names_by_domain(name1, name2, *domain)

          raise 'error: name1 or name2 does not exist' if !has_role(names[0]) || !has_role(names[1])

          role1 = create_role(names[0])
          role2 = create_role(names[1])
          role1.delete_role(role2)
        end

        def has_link(name1, name2, *domain)
          names = names_by_domain(name1, name2, *domain)

          return true if names[0] == names[1]

          return false if !has_role(names[0]) || !has_role(names[1])

          if matching_func.nil?
            role1 = create_role names[0]
            role1.has_role names[1], max_hierarchy_level
          else
            all_roles.each do |key, role|
              return true if matching_func.call(names[0], key) && role.has_role(names[1], max_hierarchy_level)
            end

            false
          end
        end

        # gets the roles that a subject inherits.
        # domain is a prefix to the roles.
        def get_roles(name, *domain)
          name = name_by_domain(name, *domain)
          return [] unless has_role(name)

          roles = create_role(name).get_roles
          if domain.size == 1
            roles.each_with_index { |value, index| roles[index] = value[domain[0].size + 2..value.size] }
          end

          roles
        end

        # gets the users that inherits a subject.
        # domain is an unreferenced parameter here, may be used in other implementations.
        def get_users(name, *domain)
          name = name_by_domain(name, *domain)
          return [] unless has_role(name)

          all_roles.map do |_key, role|
            next unless role.has_direct_role(name)

            if domain.size == 1
              role.name[domain[0].size + 2..role.name.size]
            else
              role.name
            end
          end.compact
        end

        def print_roles
          line = all_roles.map { |_key, role| role.to_string }.compact
          logger.info(line.join(', '))
        end

        private

        def names_by_domain(name1, name2, *domain)
          raise 'error: domain should be 1 parameter' if domain.size > 1

          if domain.size.zero?
            [name1, name2]
          else
            %W[#{domain[0]}::#{name1} #{domain[0]}::#{name2}]
          end
        end

        def name_by_domain(name, *domain)
          raise 'error: domain should be 1 parameter' if domain.size > 1

          domain.size == 1 ? "#{domain[0]}::#{name}" : name
        end
      end
    end
  end
end
