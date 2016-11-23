# Load up an EAD fixture
def ead_fixture(file, folder='examples')
  File.new(File.join(File.dirname(__FILE__), 'fixtures', folder, file))
end

def fixture_filepath(*args)
  File.join(File.dirname(__FILE__), 'fixtures', *args).to_s
end
