module Divshare
  module Failure; end

  class APIError < Exception
    include Failure
  end

  class ConnectionError < Exception
    include Failure
  end
end