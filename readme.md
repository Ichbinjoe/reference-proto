# Reference service

An important part of the service is turning smaller slugs into references to
larger ipfs content ids. It is also flexible enough for storing standard URIs
for referencing other resources such as websites, file servers, or really
anything that can be represented by a URI.

The reference service sits on top of libp2p as a S/Kademlia DHT under the
protocol `/iprs/ref/1.0.0`. The DHT stores a mapping of short slugs to
marshaled Reference messages. The short slug is cryptographically tied to the
Reference to which it references via a Reference provided cryptographic
function. Anyone connected to the network is able to put a new record into the
DHT provided that the Reference is properly formatted and the slug is derivable
from said Reference. All nodes MUST validate the cryptographic validity of the
slug before acting on a reference!

## What can be referenced

Reference enforces that anything it references is representable via a standard
URI (Universal resource identifier). This URI MUST be less than 512 bytes large
- this is in interest of keeping records small.

Clients are encouraged to support the following protocols:

+ `dweb`
+ `http`
+ `https`
+ `ipfs`

Other protocols may also be referenced, but referring to the protocols in other
implementations may not work as expected (or at all)!

## Creating a reference

The value for a reference in the DHT is simply the marshaled Reference protobuf
object. Of note, both hashing and encoding parameters need to be chosen. These
options are documented in `reference.proto`.

## Creating a short slug from the reference

Reference supports variably sized slugs. Slugs are stored as keys in their
encoded form which is specified inside of their Reference. This should always be
fine, as we will only ever care about it again if we want to validate the short
slug's value.

The entire marshaled Reference is hashed via parameters set within the Reference
to generate the Reference's hash. This hash is of a length defined by each hash
method (some are variable depending on the desired slug length, some are fixed
regardless). We know how many bits a short slug requires based on the desired
slug length as well as the selected slug encoding. The short slug is then the
appropriately encoded first x required bits of the generated hash. If the hash
generator is able to generate variable length hashes, the size should be the
smallest possible to create enough bits to be used for encoding the short slug.
It is invalid if a Reference chooses an encoding / hashing pair which is
incapable of generating enough bits for a given slug.

A slug, regardless of encoding, MUST be at least 6 characters, and may be no
longer than 20 characters.

## Security concerns

The first (and default) hash configuration uses the Argon2id algorithm. Argon2id
is known for its properties in defeating ASIC acceleration. The goal is to
heavily discourage to completely nullify the ability to 'mine' for short slugs
potentially colliding with already existing ones. We use a password hashing
algorithm to slow down this mining to a point where it becomes extremely costly
to perform.

