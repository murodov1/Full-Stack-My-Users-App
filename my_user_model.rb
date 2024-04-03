require 'sqlite3'

class User
  def initialize
    @db = SQLite3::Database.new 'db.sql'
    @db.results_as_hash = true

    create_table unless table_exists?
  end

  def create(user_info)
    begin
      @db.execute("INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)",
                  user_info.values)
    rescue SQLite3::Error => e
      puts "Error creating user: #{e.message}"
    end
  end

  def find(user_id)
    @db.execute("SELECT * FROM users WHERE id = ?", user_id).first
  end

  def all
    @db.execute("SELECT id, firstname, lastname, age, email FROM users")
  end

  def update(user_id, attribute, value)
    @db.execute("UPDATE users SET #{attribute} = ? WHERE id = ?", value, user_id)
    find(user_id)
  end

  def destroy(user_id)
    @db.execute("DELETE FROM users WHERE id = ?", user_id)
  end

  private

  def create_table
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
      );
    SQL
  end

  def table_exists?
    @db.table_info("users").any?
  end
end
