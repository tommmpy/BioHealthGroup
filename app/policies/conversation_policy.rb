class ConversationPolicy < ApplicationPolicy
  def close?
    administrador? || recepcionista?
  end

  def create?
    true
  end

  def show?
    record.users.include?(user)
  end

  def index?
    true
  end
end
