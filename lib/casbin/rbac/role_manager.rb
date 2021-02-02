# frozen_string_literal: true

module Casbin
  module Rbac
    # provides interface to define the operations for managing roles.
    class RoleManager
      def clear; end

      def add_link(_name1, _name2, *_domain); end

      def delete_link(_name1, _name2, *_domain); end

      def has_link(_name1, _name2, *_domain); end

      def get_roles(_name, *_domain); end

      def get_users(_name, *_domain); end

      def print_roles; end
    end
  end
end
