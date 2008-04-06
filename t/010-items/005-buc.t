#!perl -T
use TAEB::Test::Items (
    ["a - a +1 long sword (weapon in hand)",  {buc => 'uncursed'}],
    ["i - a blessed murky potion",            {buc => 'blessed'} ],
    ["j - a cursed skeleton key",             {buc => 'cursed'}  ],
    ["k - a scroll labeled THARR",            {buc => undef} ],
    ["l - a pick-axe",                        {buc => undef} ],
    ["l - a +0 pick-axe",                     {buc => 'uncursed'}],
    ["m - a long sword",                      {buc => undef} ],
    ["m - a blessed +4 long sword",           {buc => 'blessed'} ],
    ["m - a +4 long sword",                   {buc => 'uncursed'}],
    ["n - a clear potion",                    {buc => undef} ],
    ["n - a potion of holy water",            {buc => 'blessed'} ],
    ["o - a potion of unholy water",          {buc => 'cursed'}  ],
    ["p - a unicorn horn",                    {buc => undef} ],
    ["p - a +2 unicorn horn",                 {buc => 'uncursed'}],
);
