class Dog
    def initialize(attributes)
        attributes[:id] = attributes[:id]
        attributes.each do |key, value|
            self.class.attr_accessor(key)
            self.send("#{key}=", value)
        end
    end
    # create table
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    # drop the dogs table from the database
    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    # insert a new record into the database and return the instance.
    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    # Create a new row in the database & Return a new instance of the Dog class
    def self.create(name:, breed:)
        dog = self.new({name: name, breed: breed})
        dog.save
    end

    # that return instances of the class
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    # return an array of Dog instances for every record in the dogs table.
    def self.all
        DB[:conn].execute("SELECT * FROM dogs").map do
            |d| self.new_from_db(d)
        end
    end

    #   insert a dog into the database and then attempt to find it by calling the find_by_name method.
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map{ |d| self.new_from_db(d) }.first
    end

    # return a single Dog instance for the corresponding record in the dogs
    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map{ |d| self.new_from_db(d) }.first
    end
end