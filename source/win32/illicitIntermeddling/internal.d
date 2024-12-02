module illicitIntermeddling.internal;

struct Fn(T...)
{
  T args_;
  Address loc_;

  this(Address loc, T args)
  {
    args_ = args;
    loc_ = loc;
  }

  extern (Windows) void call()
  {
    alias FnProto = extern (Windows) void function(T);
    FnProto func = cast(FnProto) loc_;
    func(args_);
  }
}

Fn!(Args) fnCall(Args...)(Address loc, Args args)
{
  auto fn = typeof(return)(loc, args);
  fn.call();
  return fn;
}

mixin template fn(string name, ulong loc, T...)
{
  mixin("alias ", name, "_t = extern(Windows) ulong function(T);");
  mixin(name, "_t ", name, " = cast(", name, "_t)(GetModuleHandle(NULL) + loc);");
}

@nogc void write(T)(ulong address, T value)
{
  if (address < MAX_ADDRESS && address > MIN_ADDRESS && address % 4uL == 0uL)
    *cast(T*) address = value;
}

ulong resolveFunction(string moduleName, string exportedFunction)
{
  auto moduleHandle = GetModuleHandle(cast(const(wchar)*) moduleName);
  auto procAddr = GetProcAddress(cast(void*) moduleHandle, cast(const(char)*) exportedFunction);
  return cast(ulong) procAddr;
}
