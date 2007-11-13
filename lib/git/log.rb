module Git
  
  # object that holds the last X commits on given branch
  class Log
    include Enumerable
    
    @base = nil
    @commits = nil
    
    @object = nil
    @path = nil
    @count = nil
    @since = nil
    @between = nil
    
    @dirty_flag = nil
    
    def initialize(base, count = 30)
      dirty_log
      @base = base
      @count = count
    end

    def object(objectish)
      dirty_log
      @object = objectish
      return self
    end
    
    def path(path)
      dirty_log
      @path = path
      return self
    end
    
    def since(date)
      dirty_log
      @since = date
      return self
    end
    
    def between(sha1, sha2 = nil)
      dirty_log
      @between = [@base.lib.revparse(sha1), @base.lib.revparse(sha2)]
      return self
    end
    
    def to_s
      self.map { |c| c.sha }.join("\n")
    end
    

    # forces git log to run
    
    def size
      check_log
      @commits.size rescue nil
    end
    
    def each
      check_log
      @commits.each do |c|
        yield c
      end
    end
    
    def first
      check_log
      @commits.first rescue nil
    end
    
    private 
    
      def dirty_log
        @dirty_flag = true
      end
      
      def check_log
        if @dirty_flag
          run_log
          @dirty_flag = false
        end
      end
      
      # actually run the 'git log' command
      def run_log      
        log = @base.lib.log_commits(:count => @count, :object => @object, 
                                    :path_limiter => @path, :since => @since, :between => @between)
        @commits = log.map { |l| Git::Object::Commit.new(@base, l) }
      end
      
  end
  
end