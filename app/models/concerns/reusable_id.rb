module ReusableId
  extend ActiveSupport::Concern

  included do
    before_create :assign_lowest_available_id
  end

  private

  def assign_lowest_available_id
    return if id.present?
    self.id = self.class.send(:next_available_id)
  end

  class_methods do
    def next_available_id
      connection.transaction do
        connection.execute("SELECT pg_advisory_xact_lock(hashtext('#{table_name}_reusable_id'))")
        result = connection.execute(<<-SQL.squish)
          SELECT CASE
            WHEN NOT EXISTS (SELECT 1 FROM #{table_name} WHERE id = 1) THEN 1
            ELSE (
              SELECT MIN(t.id + 1)
              FROM #{table_name} t
              WHERE t.id > 0
                AND NOT EXISTS (
                  SELECT 1 FROM #{table_name} WHERE id = t.id + 1
                )
            )
          END AS next_id
        SQL
        result.first["next_id"].to_i
      end
    end
  end
end
