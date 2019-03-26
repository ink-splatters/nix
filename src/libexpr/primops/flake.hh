#include "types.hh"
#include "flakeref.hh"

#include <variant>

namespace nix {

struct Value;
class EvalState;

struct FlakeRegistry
{
    struct Entry
    {
        FlakeRef ref;
        Entry(const FlakeRef & flakeRef) : ref(flakeRef) {};
    };
    std::map<FlakeId, Entry> entries;
};

Value * makeFlakeRegistryValue(EvalState & state);

Value * makeFlakeValue(EvalState & state, std::string flakeUri, Value & v);

void writeRegistry(FlakeRegistry, Path);

struct Flake
{
    FlakeId id;
    FlakeRef ref;
    std::string description;
    Path path;
    std::vector<FlakeRef> requires;
    std::unique_ptr<FlakeRegistry> lockFile;
    Value * vProvides; // FIXME: gc
    // commit hash
    // date
    // content hash
    Flake(FlakeRef & flakeRef) : ref(flakeRef) {};
};

Flake getFlake(EvalState &, const FlakeRef &);

FlakeRegistry updateLockFile(EvalState &, Flake &);

void updateLockFile(EvalState &, std::string);
}
