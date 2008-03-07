#!perl -T
use TAEB::Test::Items (
    ["a - a +1 long sword (weapon in hand)",  {buc => 'uncursed'}],
    ["i - a blessed murky potion",            {buc => 'blessed'} ],
    ["j - a cursed skeleton key",             {buc => 'cursed'}  ],
    ["k - a scroll labeled THARR",            {buc => 'unknown'} ],
    ["l - a pick-axe",                        {buc => 'unknown'} ],
    ["l - a +0 pick-axe",                     {buc => 'uncursed'}],
    ["m - a long sword",                      {buc => 'unknown'} ],
    ["m - a blessed +4 long sword",           {buc => 'blessed'} ],
    ["m - a +4 long sword",                   {buc => 'uncursed'}],
    ["n - a clear potion",                    {buc => 'unknown'} ],
    ["n - a potion of holy water",            {buc => 'blessed'} ],
    ["o - a potion of unholy water",          {buc => 'cursed'}  ],
    ["p - a unicorn horn",                    {buc => 'unknown'} ],
    ["p - a +2 unicorn horn",                 {buc => 'uncursed'}],
);
