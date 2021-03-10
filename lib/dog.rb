class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(name:, breed:, id: nil)
      @name = name
      @breed = breed
      @id = id
      self
    end
    def save
      DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?,?)", @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  
    def update
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
    end
  
    def self.create(dog_hash)
      new(dog_hash).save
    end
  
    def self.new_from_db(row)
      id, name, breed = row
      new(name:name, breed:breed, id: id)
    end
  
    def self.find_by_id(id)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
      new_from_db(dog)
    end
  
    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        new_from_db(dog[0])
      else
        create({name: name, breed: breed})
      end
    end
  
    def self.find_by_name(name)
      new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
    end
  
    def self.create_table
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end
    def self.drop_table
      DB[:conn].execute("DROP TABLE dogs")
    end
  end