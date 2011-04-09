package TAEB::AI::Behavioral::Meta::Types;
use Moose::Util::TypeConstraints;

enum 'TAEB::Type::Urgency' => [qw(critical important normal unimportant fallback none)];

1;
