class Base
  def self.set_connection(client)
    @@client = client
  end

  def self.client
    @@client
  end
end
