# Tarea para resetear la secuencia de primary key para tablas Postgres
# Uso: bin/rails reset_pk:all OR bin/rails reset_pk:table[TABLENAME]
namespace :reset_pk do
  desc "Resetear secuencia PK de una tabla (Postgres). Uso: rake reset_pk:table[TABLENAME]"
  task :table, [ :table ] => :environment do |t, args|
    table = args[:table]
    unless table
      puts "Debes indicar el nombre de la tabla: rake reset_pk:table[TABLENAME]"
      next
    end
    if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
      begin
        ActiveRecord::Base.connection.reset_pk_sequence!(table)
        puts "Secuencia reiniciada para #{table}"
      rescue => e
        puts "Error: #{e.message}"
      end
    else
      puts "Reset de secuencias no soportado en esta conexión."
    end
  end

  desc "Resetear secuencias para tablas comunes: sessions, estudios, users"
  task all: :environment do
    %w[sessions estudios users].each do |t|
      Rake::Task["reset_pk:table"].invoke(t)
    end
  end
end
