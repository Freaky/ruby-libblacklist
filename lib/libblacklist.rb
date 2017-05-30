require "libblacklist/version"
require 'ffi'

module Libblacklist
  module Action
    AUTH_OK           = 0
    AUTH_FAIL         = 1
    ABUSIVE_BEHAVIOUR = 2
    BAD_USER          = 3
  end

  module LibBlacklist
    extend FFI::Library
    ffi_lib 'blacklist'

    attach_variable :errno, :int

    # struct blacklist *blacklist_open(void)
    attach_function :blacklist_open, [], :pointer

    # void blacklist_close(struct blacklist *)
    attach_function :blacklist_close, [:pointer], :void

    # int blacklist(int action, int fd, char *msg)
    attach_function :blacklist, [:int, :int, :string], :int

    # int blacklist_r(struct blacklist *, int action, int fd, char *msg)
    attach_function :blacklist_r, [:pointer, :int, :int, :string], :int

    # int blacklist_sa(int action, int fd, struct sockaddr *, socklen_t salen, char *msg)
    attach_function :blacklist_sa, [:pointer, :int, :int, :pointer, :size_t, :string], :int

    # int blacklist_sa_r(struct blacklist *, int action, int fd, struct sockaddr *, socklen_t salen, char *msg)
    attach_function :blacklist_sa_r, [:pointer, :int, :int, :pointer, :size_t, :string], :int
  end

  def open
    handle = LibBlacklist.blacklist_open

    if handle.null?
      raise SystemCallError.new("blacklist_open", LibBlacklist.errno)
    else
      return FFI::AutoPointer.new(handle, LibBlacklist.method(:blacklist_close))
    end
  end

  def close(handle)
    raise ArgumentError unless handle.kind_of? FFI::Pointer

    LibBlacklist.blacklist_close(handle)
  end

  def blacklist(action, io, msg)
    action = Integer(action)
    fd = io.fileno
    msg = msg.to_s

    LibBlacklist.blacklist(action, fd, msg)
  end

  def blacklist_r(handle, action, io, msg)
    raise ArgumentError unless handle.kind_of? FFI::Pointer

    action = Integer(action)
    fd = io.fileno
    msg = msg.to_s

    LibBlacklist.blacklist_r(handle, action, fd, msg)
  end

  def blacklist_sa(action, io, sockaddr, msg)
    action = Integer(action)
    fd = io.fileno
    sa = sockaddr.to_sockaddr
    msg = msg.to_s

    LibBlacklist.blacklist_sa(action, fd, sa, sa.bytesize, msg)
  end

  def blacklist_sa_r(handle, action, io, sockaddr, msg)
    raise ArgumentError unless handle.kind_of? FFI::Pointer

    action = Integer(action)
    fd = io.fileno
    sa = sockaddr.to_sockaddr
    msg = msg.to_s

    LibBlacklist.blacklist_sa(handle, action, fd, sa, sa.bytesize, msg)
  end

  module_function :open
  module_function :close
  module_function :blacklist
  module_function :blacklist_r
  module_function :blacklist_sa
  module_function :blacklist_sa_r
end

class BlacklistD
  def initialize
    @handle = Libblacklist.open
  end

  def close
    Libblacklist.close(@handle)
    @handle = nil
  end

  def auth_ok(io, addr: nil)
    blacklist(io: io, addr: addr, action: Libblacklist::Action::AUTH_OK, msg: "ok")
  end

  def auth_fail(io, addr: nil)
    blacklist(io: io, addr: addr, action: Libblacklist::Action::AUTH_FAIL, msg: "auth fail")
  end

  def abusive(io, addr: nil)
    blacklist(io: io, addr: addr, action: Libblacklist::Action::ABUSIVE_BEHAVIOUR, msg: "abusive")
  end

  def bad_user(io, addr: nil)
    blacklist(io: io, addr: addr, action: Libblacklist::Action::BAD_USER, msg: "bad user")
  end

  private
  def blacklist(io:, action:, addr:, msg:)
    raise "Closed" unless @handle
    if addr
      Libblacklist.blacklist_sa_r(@handle, action, io, addr, msg)
    else
      Libblacklist.blacklist_r(@handle, action, io, msg)
    end
  end
end
