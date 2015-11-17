require 'spec_helper'

class Teacher < InteractiveRecord
end

class Parent < InteractiveRecord
end

describe Parent do
  before :each do 
    DB = {:conn => SQLite3::Database.new("db/parents.db")}
    DB[:conn].execute("DROP TABLE IF EXISTS parents")

    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS parents (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      profession TEXT
      )
    SQL

    DB[:conn].execute(sql)
    DB[:conn].results_as_hash = true
  end

  let(:attributes) {
    {
      id: nil,
      name: "Peter",
      profession: "Programmer"
    } 
  }
  
  let(:new_parent) {Parent.new(attributes)}

  describe '.table_name' do 
    it 'creates a downcased, plural table name based on the Class name' do 
      expect(Parent.table_name).to eq('parents')
    end
  end

  describe '.column_names' do 
    it 'returns an array of SQL column names' do 
      expect(Parent.column_names).to eq(["id", "name", "profession"])
    end
  end

  describe 'initialize' do 
    it 'creates an new instance of a parent' do 
      expect(Parent.new).to be_a Parent
    end

    it 'creates a new parent with attributes' do 
      expect(new_parent.name).to eq("Peter")
    end
  end  
  
  describe 'attr_accessor' do 
    it 'creates attr_accessors for each column name' do 
      old_name = new_parent.name
      new_name = new_parent.name = "Jo"
      old_profession = new_parent.profession
      new_profession = new_parent.profession = "Engineer"
      expect(old_name).to eq("Sam")
      expect(new_name).to eq("Jo")
      expect(old_profession).to eq("Programmer")
      expect(new_profession).to eq("Engineer")
    end
  end

  context 'has instance methods to insert data into db' do 
    describe '#table_name_for_insert' do 
      it 'return the table name when called on an instance of Parent' do 
        expect(new_parent.table_name_for_insert).to eq("parents")
      end
    end

    describe '#col_names_for_insert' do 
      it 'return the column names when called on an instance of Parent' do 
        expect(new_parent.col_names_for_insert).to include("name, profession")
      end

      it 'does not include an id column' do 
        expect(new_parent.col_names_for_insert).not_to include("id")
      end
    end

    describe '#values_for_insert' do 
      it 'formats the column names to be used in s SQL statement' do 
        expect(new_parent.values_for_insert).to eq("'Peter', 'Programmer'")
      end
    end
    
    describe '#save' do 
      it 'saves the parent to the db' do 
        new_parent.save
        expect(DB[:conn].execute("SELECT * FROM parents WHERE name = 'Peter'")).to eq([{"id"=>1, "name"=>"Peter", "profession"=>"Programmer", 0=>1, 1=>"Peter", 2=>"Programmer"}])
      end

      it 'sets the parent\'s id' do
        new_parent.save
        expect(new_parent.id).to eq(2)
      end
    end
  end

  describe '.find_by_name' do 
    it 'executes the SQL to find a row by name' do 
      Parent.new({name: "Jan", profession: "Sales"}).save
      expect(Parent.find_by_name("Jan")).to eq([{"id"=>3, "name"=>"Jan", "profession"=>"Sales", 0=>3, 1=>"Jan", 2=>"Sales"}])
    end
  end
end