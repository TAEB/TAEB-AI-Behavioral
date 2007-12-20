#!/usr/bin/env perl
package TAEB::Knowledge::Monster;
use Moose;

# gigantic hash of monsters...
has 'monst' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        return {
            'rope golem' => {
                              'atk' => '1d4 1d4 H6d1',
                              'spd' => 9,
                              'ac' => 8,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 450,
                                            'nutrition' => 0
                                          },
                              'res' => 'sp',
                              'lev' => 4,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => '\''
                            },
            'ape' => {
                       'atk' => '1d3 1d3 1d6',
                       'spd' => 12,
                       'ac' => 6,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1100,
                                     'nutrition' => 500
                                   },
                       'res' => ' ',
                       'lev' => 4,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'Y'
                     },
            'trapper' => {
                           'atk' => 'E1d10d',
                           'spd' => 3,
                           'ac' => 3,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 800,
                                         'nutrition' => 350
                                       },
                           'res' => ' ',
                           'lev' => 12,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 't'
                         },
            'yeti' => {
                        'atk' => '1d6 1d6 1d4',
                        'spd' => 15,
                        'ac' => 6,
                        'corpse' => {
                                      'cold' => '33',
                                      'cannibal' => 0,
                                      'weight' => 1600,
                                      'nutrition' => 700
                                    },
                        'res' => 'C',
                        'lev' => 5,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'Y'
                      },
            'werewolf' => {
                            'atk' => 'W2d4',
                            'spd' => 12,
                            'ac' => 10,
                            'corpse' => {
                                          'lycanthropy' => '100',
                                          'cannibal' => 'Hum',
                                          'weight' => 1450,
                                          'poisonous' => 1,
                                          'nutrition' => 400
                                        },
                            'res' => 'p',
                            'lev' => 5,
                            'elbereth' => 0,
                            'mr' => 20,
                            'glyph' => '@'
                          },
            'wood nymph' => {
                              'atk' => '0d0- 0d0-',
                              'spd' => 12,
                              'ac' => 9,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 600,
                                            'nutrition' => 300,
                                            'teleportitis' => '30'
                                          },
                              'res' => ' ',
                              'lev' => 3,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'n'
                            },
            'fog cloud' => {
                             'atk' => 'E1d6',
                             'spd' => 1,
                             'ac' => 0,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 0,
                                           'nutrition' => 0
                                         },
                             'res' => 'sp*',
                             'lev' => 3,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'v'
                           },
            'iron golem' => {
                              'atk' => 'W4d10 B4d6P',
                              'spd' => 6,
                              'ac' => 3,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 2000,
                                            'nutrition' => 0
                                          },
                              'res' => 'fcsep',
                              'lev' => 18,
                              'elbereth' => 1,
                              'mr' => 60,
                              'glyph' => '\''
                            },
            'aligned priest' => {
                                  'atk' => 'W4d10 1d4 M0d0+',
                                  'spd' => 12,
                                  'ac' => 10,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 1450,
                                                'nutrition' => 400
                                              },
                                  'res' => 'e',
                                  'lev' => 12,
                                  'elbereth' => 0,
                                  'mr' => 50,
                                  'glyph' => '@'
                                },
            'orc mummy' => {
                             'atk' => '1d6',
                             'spd' => 10,
                             'ac' => 5,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 850,
                                           'nutrition' => 75
                                         },
                             'res' => 'csp',
                             'lev' => 5,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'M'
                           },
            'brown mold' => {
                              'atk' => '(0d6C)',
                              'spd' => 0,
                              'ac' => 9,
                              'corpse' => {
                                            'poison' => '3',
                                            'cold' => '3',
                                            'cannibal' => 0,
                                            'weight' => 50,
                                            'nutrition' => 30
                                          },
                              'res' => 'CP',
                              'lev' => 1,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'F'
                            },
            'soldier' => {
                           'atk' => 'W1d8',
                           'spd' => 10,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 6,
                           'elbereth' => 0,
                           'mr' => 0,
                           'glyph' => '@'
                         },
            'wumpus' => {
                          'atk' => '3d6',
                          'spd' => 3,
                          'ac' => 2,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 2500,
                                        'nutrition' => 500
                                      },
                          'res' => ' ',
                          'lev' => 8,
                          'elbereth' => 1,
                          'mr' => 10,
                          'glyph' => 'q'
                        },
            'apprentice' => {
                              'atk' => 'W1d6 M0d0+',
                              'spd' => 12,
                              'ac' => 10,
                              'corpse' => {
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 400
                                          },
                              'res' => ' ',
                              'lev' => 5,
                              'elbereth' => 0,
                              'mr' => 30,
                              'glyph' => '@'
                            },
            'lich' => {
                        'atk' => '1d10C M0d0+',
                        'spd' => 6,
                        'ac' => 0,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1200,
                                      'nutrition' => 0
                                    },
                        'res' => 'Csp',
                        'lev' => 11,
                        'elbereth' => 1,
                        'mr' => 30,
                        'glyph' => 'L'
                      },
            'large dog' => {
                             'atk' => '2d4',
                             'spd' => 15,
                             'ac' => 4,
                             'corpse' => {
                                           'aggravate' => 1,
                                           'cannibal' => 0,
                                           'weight' => 800,
                                           'nutrition' => 250
                                         },
                             'res' => ' ',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'd'
                           },
            'large mimic' => {
                               'atk' => '3d4m',
                               'spd' => 3,
                               'ac' => 7,
                               'corpse' => {
                                             'mimic' => '40',
                                             'cannibal' => 0,
                                             'weight' => 600,
                                             'nutrition' => 400
                                           },
                               'res' => 'a',
                               'lev' => 8,
                               'elbereth' => 1,
                               'mr' => 10,
                               'glyph' => 'm'
                             },
            'kobold' => {
                          'atk' => 'W1d4',
                          'spd' => 6,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 400,
                                        'poisonous' => 1,
                                        'nutrition' => 100
                                      },
                          'res' => 'p',
                          'lev' => 0,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'k'
                        },
            'chieftain' => {
                             'atk' => 'W1d6',
                             'spd' => 12,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => 'p',
                             'lev' => 5,
                             'elbereth' => 0,
                             'mr' => 10,
                             'glyph' => '@'
                           },
            'ice vortex' => {
                              'atk' => 'E1d6C',
                              'spd' => 20,
                              'ac' => 2,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 0,
                                            'nutrition' => 0
                                          },
                              'res' => 'csp*',
                              'lev' => 5,
                              'elbereth' => 1,
                              'mr' => 30,
                              'glyph' => 'v'
                            },
            'baby white dragon' => {
                                     'atk' => '2d6',
                                     'spd' => 9,
                                     'ac' => 2,
                                     'corpse' => {
                                                   'cannibal' => 0,
                                                   'weight' => 1500,
                                                   'nutrition' => 500
                                                 },
                                     'res' => 'c',
                                     'lev' => 12,
                                     'elbereth' => 1,
                                     'mr' => 10,
                                     'glyph' => 'D'
                                   },
            'captain' => {
                           'atk' => 'W4d4 W4d4',
                           'spd' => 10,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 12,
                           'elbereth' => 0,
                           'mr' => 15,
                           'glyph' => '@'
                         },
            'black light' => {
                               'atk' => 'X10d12h',
                               'spd' => 15,
                               'ac' => 0,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 0,
                                             'nutrition' => 0
                                           },
                               'res' => 'fcsdepa*',
                               'lev' => 5,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'y'
                             },
            'newt' => {
                        'atk' => '1d2',
                        'spd' => 6,
                        'ac' => 8,
                        'corpse' => {
                                      'energy' => '67',
                                      'cannibal' => 0,
                                      'weight' => 10,
                                      'nutrition' => 20
                                    },
                        'res' => ' ',
                        'lev' => 0,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => ':'
                      },
            'arch-lich' => {
                             'atk' => '5d6C M0d0+',
                             'spd' => 9,
                             'ac' => -6,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1200,
                                           'nutrition' => 0
                                         },
                             'res' => 'FCsep',
                             'lev' => 25,
                             'elbereth' => 1,
                             'mr' => 90,
                             'glyph' => 'L'
                           },
            'hobbit' => {
                          'atk' => 'W1d6',
                          'spd' => 9,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 500,
                                        'nutrition' => 200
                                      },
                          'res' => ' ',
                          'lev' => 1,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'h'
                        },
            'baby red dragon' => {
                                   'atk' => '2d6',
                                   'spd' => 9,
                                   'ac' => 2,
                                   'corpse' => {
                                                 'cannibal' => 0,
                                                 'weight' => 1500,
                                                 'nutrition' => 500
                                               },
                                   'res' => 'f',
                                   'lev' => 12,
                                   'elbereth' => 1,
                                   'mr' => 10,
                                   'glyph' => 'D'
                                 },
            'couatl' => {
                          'atk' => '2d4P 1d3 H2d4w',
                          'spd' => 10,
                          'ac' => 5,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 900,
                                        'nutrition' => 0
                                      },
                          'res' => 'p',
                          'lev' => 8,
                          'elbereth' => 0,
                          'mr' => 30,
                          'glyph' => 'A'
                        },
            'gray dragon' => {
                               'atk' => 'B4d6M 3d8 1d4 1d4',
                               'spd' => 9,
                               'ac' => -1,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 4500,
                                             'nutrition' => 1500
                                           },
                               'res' => ' ',
                               'lev' => 15,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'D'
                             },
            'baby blue dragon' => {
                                    'atk' => '2d6',
                                    'spd' => 9,
                                    'ac' => 2,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 1500,
                                                  'nutrition' => 500
                                                },
                                    'res' => 'e',
                                    'lev' => 12,
                                    'elbereth' => 1,
                                    'mr' => 10,
                                    'glyph' => 'D'
                                  },
            'freezing sphere' => {
                                   'atk' => 'X4d6C',
                                   'spd' => 13,
                                   'ac' => 4,
                                   'corpse' => {
                                                 'cannibal' => 0,
                                                 'weight' => 10,
                                                 'nutrition' => 0
                                               },
                                   'res' => 'C',
                                   'lev' => 6,
                                   'elbereth' => 1,
                                   'mr' => 0,
                                   'glyph' => 'e'
                                 },
            'baby purple worm' => {
                                    'atk' => '1d6',
                                    'spd' => 3,
                                    'ac' => 5,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 600,
                                                  'nutrition' => 250
                                                },
                                    'res' => ' ',
                                    'lev' => 8,
                                    'elbereth' => 1,
                                    'mr' => 0,
                                    'glyph' => 'w'
                                  },
            'rock troll' => {
                              'atk' => 'W3d6 2d8 2d6',
                              'spd' => 12,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1200,
                                            'nutrition' => 300
                                          },
                              'res' => ' ',
                              'lev' => 9,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'T'
                            },
            'forest centaur' => {
                                  'atk' => 'W1d8 1d6',
                                  'spd' => 18,
                                  'ac' => 3,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 2550,
                                                'nutrition' => 600
                                              },
                                  'res' => ' ',
                                  'lev' => 5,
                                  'elbereth' => 1,
                                  'mr' => 10,
                                  'glyph' => 'C'
                                },
            'quivering blob' => {
                                  'atk' => '1d8',
                                  'spd' => 1,
                                  'ac' => 8,
                                  'corpse' => {
                                                'poison' => '33',
                                                'cannibal' => 0,
                                                'weight' => 200,
                                                'nutrition' => 100
                                              },
                                  'res' => 'sP',
                                  'lev' => 5,
                                  'elbereth' => 1,
                                  'mr' => 0,
                                  'glyph' => 'b'
                                },
            'minotaur' => {
                            'atk' => '3d10 3d10 2d8',
                            'spd' => 15,
                            'ac' => 6,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1500,
                                          'nutrition' => 700
                                        },
                            'res' => ' ',
                            'lev' => 15,
                            'elbereth' => 0,
                            'mr' => 0,
                            'glyph' => 'H'
                          },
            'red naga hatchling' => {
                                      'atk' => '1d4',
                                      'spd' => 10,
                                      'ac' => 6,
                                      'corpse' => {
                                                    'poison' => '10',
                                                    'cannibal' => 0,
                                                    'fire' => '10',
                                                    'weight' => 500,
                                                    'nutrition' => 100
                                                  },
                                      'res' => 'FP',
                                      'lev' => 3,
                                      'elbereth' => 1,
                                      'mr' => 0,
                                      'glyph' => 'N'
                                    },
            'blue jelly' => {
                              'atk' => '(0d6C)',
                              'spd' => 0,
                              'ac' => 8,
                              'corpse' => {
                                            'poison' => '13',
                                            'cold' => '13',
                                            'cannibal' => 0,
                                            'weight' => 50,
                                            'nutrition' => 20
                                          },
                              'res' => 'CP',
                              'lev' => 4,
                              'elbereth' => 1,
                              'mr' => 10,
                              'glyph' => 'j'
                            },
            'Twoflower' => {
                             'atk' => 'W1d6 W1d6',
                             'spd' => 12,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => ' ',
                             'lev' => 20,
                             'elbereth' => 0,
                             'mr' => 20,
                             'glyph' => '@'
                           },
            'pyrolisk' => {
                            'atk' => 'G2d6F',
                            'spd' => 6,
                            'ac' => 6,
                            'corpse' => {
                                          'poison' => '20',
                                          'cannibal' => 0,
                                          'fire' => '20',
                                          'weight' => 30,
                                          'nutrition' => 30
                                        },
                            'res' => 'FP',
                            'lev' => 6,
                            'elbereth' => 1,
                            'mr' => 30,
                            'glyph' => 'c'
                          },
            'priest' => {
                          'atk' => 'W1d6',
                          'spd' => 12,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => ' ',
                          'lev' => 10,
                          'elbereth' => 0,
                          'mr' => 2,
                          'glyph' => '@'
                        },
            'ki-rin' => {
                          'atk' => '2d4 2d4 3d6 M2d6+',
                          'spd' => 18,
                          'ac' => -5,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1450,
                                        'nutrition' => 0
                                      },
                          'res' => ' ',
                          'lev' => 16,
                          'elbereth' => 0,
                          'mr' => 90,
                          'glyph' => 'A'
                        },
            'steam vortex' => {
                                'atk' => 'E1d8F',
                                'spd' => 22,
                                'ac' => 2,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 0,
                                              'nutrition' => 0
                                            },
                                'res' => 'fsp*',
                                'lev' => 7,
                                'elbereth' => 1,
                                'mr' => 30,
                                'glyph' => 'v'
                              },
            'caveman' => {
                           'atk' => 'W2d4',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 10,
                           'elbereth' => 0,
                           'mr' => 0,
                           'glyph' => '@'
                         },
            'warg' => {
                        'atk' => '2d6',
                        'spd' => 12,
                        'ac' => 4,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 850,
                                      'nutrition' => 350
                                    },
                        'res' => ' ',
                        'lev' => 7,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'd'
                      },
            'purple worm' => {
                               'atk' => '2d8 E1d10d',
                               'spd' => 9,
                               'ac' => 6,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 2700,
                                             'nutrition' => 700
                                           },
                               'res' => ' ',
                               'lev' => 15,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'w'
                             },
            'frost giant' => {
                               'atk' => 'W2d12',
                               'spd' => 12,
                               'ac' => 3,
                               'corpse' => {
                                             'cold' => '33',
                                             'cannibal' => 0,
                                             'weight' => 2250,
                                             'nutrition' => 750,
                                             'strength' => 1
                                           },
                               'res' => 'C',
                               'lev' => 10,
                               'elbereth' => 1,
                               'mr' => 10,
                               'glyph' => 'H'
                             },
            'Juiblex' => {
                           'atk' => 'E4d10# S3d6A',
                           'spd' => 3,
                           'ac' => -7,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1500,
                                         'nutrition' => 0
                                       },
                           'res' => 'fpa*',
                           'lev' => 50,
                           'elbereth' => 1,
                           'mr' => 65,
                           'glyph' => '&'
                         },
            'marilith' => {
                            'atk' => 'W2d4 W2d4 2d4 2d4 2d4 2d4',
                            'spd' => 12,
                            'ac' => -6,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1450,
                                          'nutrition' => 0
                                        },
                            'res' => 'fp',
                            'lev' => 7,
                            'elbereth' => 1,
                            'mr' => 80,
                            'glyph' => '&'
                          },
            'floating eye' => {
                                'atk' => '(0d70.)',
                                'spd' => 1,
                                'ac' => 9,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 10,
                                              'nutrition' => 10,
                                              'telepathy' => '100'
                                            },
                                'res' => ' ',
                                'lev' => 2,
                                'elbereth' => 1,
                                'mr' => 10,
                                'glyph' => 'e'
                              },
            'paper golem' => {
                               'atk' => '1d3',
                               'spd' => 12,
                               'ac' => 10,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 400,
                                             'nutrition' => 0
                                           },
                               'res' => 'sp',
                               'lev' => 3,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => '\''
                             },
            'kitten' => {
                          'atk' => '1d6',
                          'spd' => 18,
                          'ac' => 6,
                          'corpse' => {
                                        'aggravate' => 1,
                                        'cannibal' => 0,
                                        'weight' => 150,
                                        'nutrition' => 150
                                      },
                          'res' => ' ',
                          'lev' => 2,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'f'
                        },
            'Orion' => {
                         'atk' => 'W1d6',
                         'spd' => 12,
                         'ac' => 0,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 20,
                         'elbereth' => 0,
                         'mr' => 30,
                         'glyph' => '@'
                       },
            'ogre king' => {
                             'atk' => 'W3d5',
                             'spd' => 14,
                             'ac' => 4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1700,
                                           'nutrition' => 750
                                         },
                             'res' => ' ',
                             'lev' => 9,
                             'elbereth' => 1,
                             'mr' => 60,
                             'glyph' => 'O'
                           },
            'gnome king' => {
                              'atk' => 'W2d6',
                              'spd' => 10,
                              'ac' => 10,
                              'corpse' => {
                                            'cannibal' => 'Gno',
                                            'weight' => 750,
                                            'nutrition' => 150
                                          },
                              'res' => ' ',
                              'lev' => 5,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'G'
                            },
            'baby gray dragon' => {
                                    'atk' => '2d6',
                                    'spd' => 9,
                                    'ac' => 2,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 1500,
                                                  'nutrition' => 500
                                                },
                                    'res' => ' ',
                                    'lev' => 12,
                                    'elbereth' => 1,
                                    'mr' => 10,
                                    'glyph' => 'D'
                                  },
            'human' => {
                         'atk' => 'W1d6',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 0,
                         'elbereth' => 0,
                         'mr' => 0,
                         'glyph' => '@'
                       },
            'lichen' => {
                          'atk' => '0d0m',
                          'spd' => 1,
                          'ac' => 9,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 20,
                                        'nutrition' => 200
                                      },
                          'res' => ' ',
                          'lev' => 0,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'F'
                        },
            'dwarf zombie' => {
                                'atk' => '1d6',
                                'spd' => 6,
                                'ac' => 9,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 900,
                                              'nutrition' => 150
                                            },
                                'res' => 'csp',
                                'lev' => 2,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'Z'
                              },
            'mountain nymph' => {
                                  'atk' => '0d0- 0d0-',
                                  'spd' => 12,
                                  'ac' => 9,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 600,
                                                'nutrition' => 300,
                                                'teleportitis' => '30'
                                              },
                                  'res' => ' ',
                                  'lev' => 3,
                                  'elbereth' => 1,
                                  'mr' => 20,
                                  'glyph' => 'n'
                                },
            'Hippocrates' => {
                               'atk' => 'W1d6',
                               'spd' => 12,
                               'ac' => 0,
                               'corpse' => {
                                             'cannibal' => 'Hum',
                                             'weight' => 1450,
                                             'nutrition' => 400
                                           },
                               'res' => 'p',
                               'lev' => 20,
                               'elbereth' => 0,
                               'mr' => 40,
                               'glyph' => '@'
                             },
            'Pestilence' => {
                              'atk' => '8d8z 8d8z',
                              'spd' => 12,
                              'ac' => -5,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1450,
                                            'die' => 1,
                                            'nutrition' => 1
                                          },
                              'res' => 'fcsep*',
                              'lev' => 30,
                              'elbereth' => 0,
                              'mr' => 100,
                              'glyph' => '&'
                            },
            'quasit' => {
                          'atk' => '1d2!D 1d2!D 1d4',
                          'spd' => 15,
                          'ac' => 2,
                          'corpse' => {
                                        'poison' => '20',
                                        'cannibal' => 0,
                                        'weight' => 200,
                                        'nutrition' => 200
                                      },
                          'res' => 'P',
                          'lev' => 3,
                          'elbereth' => 1,
                          'mr' => 20,
                          'glyph' => 'i'
                        },
            'skeleton' => {
                            'atk' => 'W2d6 1d6&lt;',
                            'spd' => 8,
                            'ac' => 4,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 300,
                                          'nutrition' => 0
                                        },
                            'res' => 'csp*',
                            'lev' => 12,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'Z'
                          },
            'Uruk-hai' => {
                            'atk' => 'W1d8',
                            'spd' => 7,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1300,
                                          'nutrition' => 300
                                        },
                            'res' => ' ',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'o'
                          },
            'knight' => {
                          'atk' => 'W1d6 W1d6',
                          'spd' => 12,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => ' ',
                          'lev' => 10,
                          'elbereth' => 0,
                          'mr' => 1,
                          'glyph' => '@'
                        },
            'Baalzebub' => {
                             'atk' => '2d6P G2d6s',
                             'spd' => 9,
                             'ac' => -5,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1500,
                                           'nutrition' => 0
                                         },
                             'res' => 'fp',
                             'lev' => 89,
                             'elbereth' => 1,
                             'mr' => 85,
                             'glyph' => '&'
                           },
            'Kop Kaptain' => {
                               'atk' => 'W2d6',
                               'spd' => 12,
                               'ac' => 10,
                               'corpse' => {
                                             'cannibal' => 'Hum',
                                             'weight' => 1450,
                                             'nutrition' => 200
                                           },
                               'res' => ' ',
                               'lev' => 4,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'K'
                             },
            'guardian naga' => {
                                 'atk' => '1d6. S1d6P H2d4',
                                 'spd' => 16,
                                 'ac' => 0,
                                 'corpse' => {
                                               'poison' => '80',
                                               'cannibal' => 0,
                                               'weight' => 2600,
                                               'poisonous' => 1,
                                               'nutrition' => 400
                                             },
                                 'res' => 'P',
                                 'lev' => 12,
                                 'elbereth' => 0,
                                 'mr' => 50,
                                 'glyph' => 'N'
                               },
            'golden naga hatchlin' => {
                                        'corpse' => {
                                                      'weight' => 500,
                                                      'nutrition' => 100
                                                    }
                                      },
            'abbot' => {
                         'atk' => '8d2 3d2s M0d0+',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'hallucination' => 1,
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 0,
                         'mr' => 20,
                         'glyph' => '@'
                       },
            'xorn' => {
                        'atk' => '1d3 1d3 1d3 4d6',
                        'spd' => 9,
                        'ac' => -2,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1200,
                                      'nutrition' => 700
                                    },
                        'res' => 'fc*',
                        'lev' => 8,
                        'elbereth' => 1,
                        'mr' => 20,
                        'glyph' => 'X'
                      },
            'wolf' => {
                        'atk' => '2d4',
                        'spd' => 12,
                        'ac' => 4,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 500,
                                      'nutrition' => 250
                                    },
                        'res' => ' ',
                        'lev' => 5,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'd'
                      },
            'yellow light' => {
                                'atk' => 'X10d20b',
                                'spd' => 15,
                                'ac' => 0,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 0,
                                              'nutrition' => 0
                                            },
                                'res' => 'fcsdepa*',
                                'lev' => 3,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'y'
                              },
            'black pudding' => {
                                 'atk' => '3d8R (0d0R)',
                                 'spd' => 6,
                                 'ac' => 6,
                                 'corpse' => {
                                               'poison' => '22',
                                               'cold' => '22',
                                               'shock' => '22',
                                               'nutrition' => 250,
                                               'cannibal' => 0,
                                               'weight' => 900,
                                               'acidic' => 1
                                             },
                                 'res' => 'CEPa*',
                                 'lev' => 10,
                                 'elbereth' => 1,
                                 'mr' => 0,
                                 'glyph' => 'P'
                               },
            'Keystone Kop' => {
                                'atk' => 'W1d4',
                                'spd' => 6,
                                'ac' => 10,
                                'corpse' => {
                                              'cannibal' => 'Hum',
                                              'weight' => 1450,
                                              'nutrition' => 200
                                            },
                                'res' => ' ',
                                'lev' => 1,
                                'elbereth' => 1,
                                'mr' => 10,
                                'glyph' => 'K'
                              },
            'hill giant' => {
                              'atk' => 'W2d8',
                              'spd' => 10,
                              'ac' => 6,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 2200,
                                            'nutrition' => 700,
                                            'strength' => 1
                                          },
                              'res' => ' ',
                              'lev' => 8,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'H'
                            },
            'dust vortex' => {
                               'atk' => 'E2d8b',
                               'spd' => 20,
                               'ac' => 2,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 0,
                                             'nutrition' => 0
                                           },
                               'res' => 'sp*',
                               'lev' => 4,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'v'
                             },
            'giant beetle' => {
                                'atk' => '3d6',
                                'spd' => 6,
                                'ac' => 4,
                                'corpse' => {
                                              'poison' => '33',
                                              'cannibal' => 0,
                                              'weight' => 10,
                                              'poisonous' => 1,
                                              'nutrition' => 10
                                            },
                                'res' => 'P',
                                'lev' => 5,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'a'
                              },
            'shrieker' => {
                            'atk' => '',
                            'spd' => 1,
                            'ac' => 7,
                            'corpse' => {
                                          'poison' => '20',
                                          'cannibal' => 0,
                                          'weight' => 100,
                                          'nutrition' => 100
                                        },
                            'res' => 'P',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'F'
                          },
            'Neferet the Green' => {
                                     'atk' => 'W1d6 M2d8+',
                                     'spd' => 12,
                                     'ac' => 0,
                                     'corpse' => {
                                                   'cannibal' => 'Hum',
                                                   'weight' => 1450,
                                                   'nutrition' => 400
                                                 },
                                     'res' => ' ',
                                     'lev' => 20,
                                     'elbereth' => 0,
                                     'mr' => 60,
                                     'glyph' => '@'
                                   },
            'gray unicorn' => {
                                'atk' => '1d12 1d6',
                                'spd' => 24,
                                'ac' => 2,
                                'corpse' => {
                                              'poison' => '27',
                                              'cannibal' => 0,
                                              'weight' => 1300,
                                              'nutrition' => 300
                                            },
                                'res' => 'P',
                                'lev' => 4,
                                'elbereth' => 1,
                                'mr' => 70,
                                'glyph' => 'u'
                              },
            'acid blob' => {
                             'atk' => '(1d8A)',
                             'spd' => 3,
                             'ac' => 8,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 30,
                                           'nutrition' => 10,
                                           'acidic' => 1
                                         },
                             'res' => 'spa*',
                             'lev' => 1,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'b'
                           },
            'giant ant' => {
                             'atk' => '1d4',
                             'spd' => 18,
                             'ac' => 3,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 10,
                                           'nutrition' => 10
                                         },
                             'res' => ' ',
                             'lev' => 2,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'a'
                           },
            'large kobold' => {
                                'atk' => 'W1d6',
                                'spd' => 6,
                                'ac' => 10,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 450,
                                              'poisonous' => 1,
                                              'nutrition' => 150
                                            },
                                'res' => 'p',
                                'lev' => 1,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'k'
                              },
            'yellow mold' => {
                               'atk' => '(0d4s)',
                               'spd' => 0,
                               'ac' => 9,
                               'corpse' => {
                                             'hallucination' => 1,
                                             'poison' => '7',
                                             'poisonous' => 1,
                                             'nutrition' => 30,
                                             'cannibal' => 0,
                                             'weight' => 50
                                           },
                               'res' => 'P',
                               'lev' => 1,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'F'
                             },
            'long worm' => {
                             'atk' => '1d4',
                             'spd' => 3,
                             'ac' => 5,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1500,
                                           'nutrition' => 500
                                         },
                             'res' => ' ',
                             'lev' => 8,
                             'elbereth' => 1,
                             'mr' => 10,
                             'glyph' => 'w'
                           },
            'Thoth Amon' => {
                              'atk' => 'W1d6 M0d0+ M0d0+ 1d4-',
                              'spd' => 12,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1450,
                                            'nutrition' => 0
                                          },
                              'res' => 'p*',
                              'lev' => 16,
                              'elbereth' => 0,
                              'mr' => 10,
                              'glyph' => '@'
                            },
            'red mold' => {
                            'atk' => '(0d4F)',
                            'spd' => 0,
                            'ac' => 9,
                            'corpse' => {
                                          'poison' => '3',
                                          'cannibal' => 0,
                                          'fire' => '3',
                                          'weight' => 50,
                                          'nutrition' => 30
                                        },
                            'res' => 'FP',
                            'lev' => 1,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'F'
                          },
            'erinys' => {
                          'atk' => 'W2d4P',
                          'spd' => 12,
                          'ac' => 2,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1450,
                                        'nutrition' => 0
                                      },
                          'res' => 'fp',
                          'lev' => 7,
                          'elbereth' => 1,
                          'mr' => 30,
                          'glyph' => '&'
                        },
            'bat' => {
                       'atk' => '1d4',
                       'spd' => 22,
                       'ac' => 8,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 20,
                                     'stun' => '30',
                                     'nutrition' => 20
                                   },
                       'res' => ' ',
                       'lev' => 0,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'B'
                     },
            'elf mummy' => {
                             'atk' => '2d4',
                             'spd' => 12,
                             'ac' => 4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 800,
                                           'nutrition' => 175
                                         },
                             'res' => 'csp',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 30,
                             'glyph' => 'M'
                           },
            'elf-lord' => {
                            'atk' => 'W2d4 W2d4',
                            'spd' => 12,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 'Elf',
                                          'weight' => 800,
                                          'nutrition' => 350,
                                          'sleep' => '53'
                                        },
                            'res' => 'S',
                            'lev' => 8,
                            'elbereth' => 0,
                            'mr' => 20,
                            'glyph' => '@'
                          },
            'gas spore' => {
                             'atk' => '[X4d6]',
                             'spd' => 3,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 10,
                                           'nutrition' => 0
                                         },
                             'res' => ' ',
                             'lev' => 1,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'e'
                           },
            'giant bat' => {
                             'atk' => '1d6',
                             'spd' => 22,
                             'ac' => 7,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 30,
                                           'stun' => '60',
                                           'nutrition' => 30
                                         },
                             'res' => ' ',
                             'lev' => 2,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'B'
                           },
            'Dark One' => {
                            'atk' => 'W1d6 W1d6 1d4- M0d0+',
                            'spd' => 12,
                            'ac' => 0,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1450,
                                          'nutrition' => 0
                                        },
                            'res' => '*',
                            'lev' => 15,
                            'elbereth' => 0,
                            'mr' => 80,
                            'glyph' => '@'
                          },
            'panther' => {
                           'atk' => '1d6 1d6 1d10',
                           'spd' => 15,
                           'ac' => 6,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 600,
                                         'nutrition' => 300
                                       },
                           'res' => ' ',
                           'lev' => 5,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'f'
                         },
            'rust monster' => {
                                'atk' => '0d0R 0d0R (0d0R)',
                                'spd' => 18,
                                'ac' => 2,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 1000,
                                              'nutrition' => 250
                                            },
                                'res' => ' ',
                                'lev' => 5,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'R'
                              },
            'fox' => {
                       'atk' => '1d3',
                       'spd' => 15,
                       'ac' => 7,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 300,
                                     'nutrition' => 250
                                   },
                       'res' => ' ',
                       'lev' => 0,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'd'
                     },
            'giant eel' => {
                             'atk' => '3d6 0d0w',
                             'spd' => 9,
                             'ac' => -1,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 200,
                                           'nutrition' => 250
                                         },
                             'res' => ' ',
                             'lev' => 5,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => ';'
                           },
            'leocrotta' => {
                             'atk' => '2d6 2d6 2d6',
                             'spd' => 18,
                             'ac' => 4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1200,
                                           'nutrition' => 500
                                         },
                             'res' => ' ',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 10,
                             'glyph' => 'q'
                           },
            'gnome zombie' => {
                                'atk' => '1d5',
                                'spd' => 6,
                                'ac' => 10,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 650,
                                              'nutrition' => 50
                                            },
                                'res' => 'csp',
                                'lev' => 1,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'Z'
                              },
            'Nazgul' => {
                          'atk' => 'W1d4V B2d25S',
                          'spd' => 12,
                          'ac' => 0,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1450,
                                        'nutrition' => 0
                                      },
                          'res' => 'csp',
                          'lev' => 13,
                          'elbereth' => 1,
                          'mr' => 25,
                          'glyph' => 'W'
                        },
            'baby long worm' => {
                                  'atk' => '1d6',
                                  'spd' => 3,
                                  'ac' => 5,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 600,
                                                'nutrition' => 250
                                              },
                                  'res' => ' ',
                                  'lev' => 8,
                                  'elbereth' => 1,
                                  'mr' => 0,
                                  'glyph' => 'w'
                                },
            'human mummy' => {
                               'atk' => '2d4 2d4',
                               'spd' => 12,
                               'ac' => 4,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 1450,
                                             'nutrition' => 200
                                           },
                               'res' => 'csp',
                               'lev' => 6,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'M'
                             },
            'violet fungi' => {
                                'corpse' => {
                                              'hallucination' => 1,
                                              'poison' => '20'
                                            }
                              },
            'pit fiend' => {
                             'atk' => 'W4d2 W4d2 H2d4',
                             'spd' => 6,
                             'ac' => -3,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1450,
                                           'nutrition' => 0
                                         },
                             'res' => 'fp',
                             'lev' => 13,
                             'elbereth' => 1,
                             'mr' => 65,
                             'glyph' => '&'
                           },
            'vampire lord' => {
                                'atk' => '1d8 1d8V',
                                'spd' => 14,
                                'ac' => 0,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 1450,
                                              'nutrition' => 400
                                            },
                                'res' => 'sp',
                                'lev' => 12,
                                'elbereth' => 1,
                                'mr' => 50,
                                'glyph' => 'V'
                              },
            'guard' => {
                         'atk' => 'W4d10',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 12,
                         'elbereth' => 0,
                         'mr' => 40,
                         'glyph' => '@'
                       },
            'shopkeeper' => {
                              'atk' => 'W4d4 W4d4',
                              'spd' => 18,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 400
                                          },
                              'res' => ' ',
                              'lev' => 12,
                              'elbereth' => 0,
                              'mr' => 50,
                              'glyph' => '@'
                            },
            'Olog-hai' => {
                            'atk' => 'W3d6 2d8 2d6',
                            'spd' => 12,
                            'ac' => -4,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1500,
                                          'nutrition' => 400
                                        },
                            'res' => ' ',
                            'lev' => 13,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'T'
                          },
            'golden naga hatchling' => {
                                         'atk' => '1d4',
                                         'spd' => 10,
                                         'ac' => 6,
                                         'corpse' => {
                                                       'poison' => '20',
                                                       'cannibal' => 0
                                                     },
                                         'res' => 'P',
                                         'lev' => 3,
                                         'elbereth' => 1,
                                         'mr' => 0,
                                         'glyph' => 'N'
                                       },
            'hobgoblin' => {
                             'atk' => 'W1d6',
                             'spd' => 9,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1000,
                                           'nutrition' => 200
                                         },
                             'res' => ' ',
                             'lev' => 1,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'o'
                           },
            'succubus' => {
                            'atk' => '0d0&amp; 1d3 1d3',
                            'spd' => 12,
                            'ac' => 0,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1450,
                                          'nutrition' => 0
                                        },
                            'res' => 'fp',
                            'lev' => 6,
                            'elbereth' => 1,
                            'mr' => 70,
                            'glyph' => '&'
                          },
            'woodchuck' => {
                             'atk' => '1d6',
                             'spd' => 3,
                             'ac' => 0,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 30,
                                           'nutrition' => 30
                                         },
                             'res' => ' ',
                             'lev' => 3,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'r'
                           },
            'winter wolf cub' => {
                                   'atk' => '1d8 B1d8C',
                                   'spd' => 12,
                                   'ac' => 4,
                                   'corpse' => {
                                                 'cold' => '33',
                                                 'cannibal' => 0,
                                                 'weight' => 250,
                                                 'nutrition' => 200
                                               },
                                   'res' => 'C',
                                   'lev' => 5,
                                   'elbereth' => 1,
                                   'mr' => 0,
                                   'glyph' => 'd'
                                 },
            'Angel' => {
                         'atk' => 'W1d6 W1d6 1d4 M2d6M',
                         'spd' => 10,
                         'ac' => -4,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1450,
                                       'nutrition' => 0
                                     },
                         'res' => 'csep',
                         'lev' => 14,
                         'elbereth' => 0,
                         'mr' => 55,
                         'glyph' => 'A'
                       },
            'human zombie' => {
                                'atk' => '1d8',
                                'spd' => 6,
                                'ac' => 8,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 1450,
                                              'nutrition' => 200
                                            },
                                'res' => 'csp',
                                'lev' => 4,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'Z'
                              },
            'golden naga' => {
                               'atk' => '2d6 M4d6+',
                               'spd' => 14,
                               'ac' => 2,
                               'corpse' => {
                                             'poison' => '67',
                                             'cannibal' => 0,
                                             'weight' => 2600,
                                             'nutrition' => 400
                                           },
                               'res' => 'P',
                               'lev' => 10,
                               'elbereth' => 1,
                               'mr' => 70,
                               'glyph' => 'N'
                             },
            'baby yellow dragon' => {
                                      'atk' => '2d6',
                                      'spd' => 9,
                                      'ac' => 2,
                                      'corpse' => {
                                                    'cannibal' => 0,
                                                    'weight' => 1500,
                                                    'nutrition' => 500,
                                                    'acidic' => 1
                                                  },
                                      'res' => 'a*',
                                      'lev' => 12,
                                      'elbereth' => 1,
                                      'mr' => 10,
                                      'glyph' => 'D'
                                    },
            'Arch Priest' => {
                               'atk' => 'W4d10 2d8 M2d8+ M2d8+',
                               'spd' => 12,
                               'ac' => 7,
                               'corpse' => {
                                             'cannibal' => 'Hum',
                                             'weight' => 1450,
                                             'nutrition' => 400
                                           },
                               'res' => 'fsep',
                               'lev' => 25,
                               'elbereth' => 0,
                               'mr' => 70,
                               'glyph' => '@'
                             },
            'winged gargoyle' => {
                                   'atk' => '3d6 3d6 3d4',
                                   'spd' => 15,
                                   'ac' => -2,
                                   'corpse' => {
                                                 'cannibal' => 0,
                                                 'weight' => 1200,
                                                 'nutrition' => 300
                                               },
                                   'res' => '*',
                                   'lev' => 9,
                                   'elbereth' => 1,
                                   'mr' => 0,
                                   'glyph' => 'g'
                                 },
            'black naga' => {
                              'atk' => '2d6 S0d0A',
                              'spd' => 14,
                              'ac' => 2,
                              'corpse' => {
                                            'poison' => '53',
                                            'cannibal' => 0,
                                            'weight' => 2600,
                                            'nutrition' => 400,
                                            'acidic' => 1
                                          },
                              'res' => 'Pa*',
                              'lev' => 8,
                              'elbereth' => 1,
                              'mr' => 10,
                              'glyph' => 'N'
                            },
            'fire giant' => {
                              'atk' => 'W2d10',
                              'spd' => 12,
                              'ac' => 4,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'fire' => '30',
                                            'weight' => 2250,
                                            'nutrition' => 750,
                                            'strength' => 1
                                          },
                              'res' => 'F',
                              'lev' => 9,
                              'elbereth' => 1,
                              'mr' => 5,
                              'glyph' => 'H'
                            },
            'orc' => {
                       'atk' => 'W1d8',
                       'spd' => 9,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 850,
                                     'nutrition' => 150
                                   },
                       'res' => ' ',
                       'lev' => 1,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'o'
                     },
            'hezrou' => {
                          'atk' => '1d3 1d3 4d4',
                          'spd' => 6,
                          'ac' => -2,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1450,
                                        'nutrition' => 0
                                      },
                          'res' => 'fp',
                          'lev' => 9,
                          'elbereth' => 1,
                          'mr' => 55,
                          'glyph' => '&'
                        },
            'winter wolf' => {
                               'atk' => '2d6 B2d6C',
                               'spd' => 12,
                               'ac' => 4,
                               'corpse' => {
                                             'cold' => '47',
                                             'cannibal' => 0,
                                             'weight' => 700,
                                             'nutrition' => 300
                                           },
                               'res' => 'C',
                               'lev' => 7,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'd'
                             },
            'mountain centaur' => {
                                    'atk' => 'W1d10 1d6 1d6',
                                    'spd' => 20,
                                    'ac' => 2,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 2550,
                                                  'nutrition' => 500
                                                },
                                    'res' => ' ',
                                    'lev' => 6,
                                    'elbereth' => 1,
                                    'mr' => 10,
                                    'glyph' => 'C'
                                  },
            'baluchitherium' => {
                                  'atk' => '5d4 5d4',
                                  'spd' => 12,
                                  'ac' => 5,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 3800,
                                                'nutrition' => 800
                                              },
                                  'res' => ' ',
                                  'lev' => 14,
                                  'elbereth' => 1,
                                  'mr' => 0,
                                  'glyph' => 'q'
                                },
            'tourist' => {
                           'atk' => 'W1d6 W1d6',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 10,
                           'elbereth' => 0,
                           'mr' => 1,
                           'glyph' => '@'
                         },
            'giant mummy' => {
                               'atk' => '3d4 3d4',
                               'spd' => 14,
                               'ac' => 3,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 2050,
                                             'nutrition' => 375
                                           },
                               'res' => 'csp',
                               'lev' => 8,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'M'
                             },
            'chickatrice' => {
                               'atk' => '1d2 0d0* (0d0*)',
                               'spd' => 4,
                               'ac' => 8,
                               'corpse' => {
                                             'poison' => '27',
                                             'petrify' => 1,
                                             'cannibal' => 0,
                                             'weight' => 10,
                                             'nutrition' => 10
                                           },
                               'res' => 'P*',
                               'lev' => 4,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'c'
                             },
            'ninja' => {
                         'atk' => 'W1d8 W1d8',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 0,
                         'mr' => 10,
                         'glyph' => '@'
                       },
            'chameleon' => {
                             'atk' => '4d2',
                             'spd' => 5,
                             'ac' => 6,
                             'corpse' => {
                                           'polymorph' => 1,
                                           'cannibal' => 0,
                                           'weight' => 100,
                                           'nutrition' => 100
                                         },
                             'res' => ' ',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 10,
                             'glyph' => ':'
                           },
            'ettin' => {
                         'atk' => 'W2d8 W3d6',
                         'spd' => 12,
                         'ac' => 3,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1700,
                                       'nutrition' => 500
                                     },
                         'res' => ' ',
                         'lev' => 10,
                         'elbereth' => 1,
                         'mr' => 0,
                         'glyph' => 'H'
                       },
            'baby orange dragon' => {
                                      'atk' => '2d6',
                                      'spd' => 9,
                                      'ac' => 2,
                                      'corpse' => {
                                                    'cannibal' => 0,
                                                    'weight' => 1500,
                                                    'nutrition' => 500
                                                  },
                                      'res' => 's',
                                      'lev' => 12,
                                      'elbereth' => 1,
                                      'mr' => 10,
                                      'glyph' => 'D'
                                    },
            'fire ant' => {
                            'atk' => '2d4 2d4F',
                            'spd' => 18,
                            'ac' => 3,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'fire' => '20',
                                          'weight' => 30,
                                          'nutrition' => 10
                                        },
                            'res' => 'F',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 10,
                            'glyph' => 'a'
                          },
            'Cyclops' => {
                           'atk' => 'W4d8 W4d8 2d6-',
                           'spd' => 12,
                           'ac' => 0,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1900,
                                         'nutrition' => 700,
                                         'strength' => 1
                                       },
                           'res' => '*',
                           'lev' => 18,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'H'
                         },
            'baby green dragon' => {
                                     'atk' => '2d6',
                                     'spd' => 9,
                                     'ac' => 2,
                                     'corpse' => {
                                                   'cannibal' => 0,
                                                   'weight' => 1500,
                                                   'poisonous' => 1,
                                                   'nutrition' => 500
                                                 },
                                     'res' => 'p',
                                     'lev' => 12,
                                     'elbereth' => 1,
                                     'mr' => 10,
                                     'glyph' => 'D'
                                   },
            'python' => {
                          'atk' => '1d4 0d0 H1d4w H2d4',
                          'spd' => 3,
                          'ac' => 5,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 250,
                                        'nutrition' => 100
                                      },
                          'res' => ' ',
                          'lev' => 6,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'S'
                        },
            'black naga hatchling' => {
                                        'atk' => '1d4',
                                        'spd' => 10,
                                        'ac' => 6,
                                        'corpse' => {
                                                      'poison' => '20',
                                                      'cannibal' => 0,
                                                      'weight' => 500,
                                                      'nutrition' => 100,
                                                      'acidic' => 1
                                                    },
                                        'res' => 'Pa*',
                                        'lev' => 3,
                                        'elbereth' => 1,
                                        'mr' => 0,
                                        'glyph' => 'N'
                                      },
            'Scorpius' => {
                            'atk' => '2d6 2d6- 1d4#',
                            'spd' => 12,
                            'ac' => 10,
                            'corpse' => {
                                          'poison' => '100',
                                          'cannibal' => 0,
                                          'weight' => 750,
                                          'poisonous' => 1,
                                          'nutrition' => 350
                                        },
                            'res' => 'P*',
                            'lev' => 15,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 's'
                          },
            'water demon' => {
                               'atk' => 'W1d3 1d3 1d3',
                               'spd' => 12,
                               'ac' => -4,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 1450,
                                             'nutrition' => 0
                                           },
                               'res' => 'fp',
                               'lev' => 8,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => '&'
                             },
            'disenchanter' => {
                                'atk' => '4d4" (0d0")',
                              'spd' => 12,
                              'ac' => -10,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 750,
                                            'nutrition' => 200
                                          },
                              'res' => ' ',
                              'lev' => 12,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'R'
                            },
          'quantum mechanic' => {
                                  'atk' => '1d4t',
                                  'spd' => 12,
                                  'ac' => 3,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 1450,
                                                'poisonous' => 1,
                                                'nutrition' => 20
                                              },
                                  'res' => 'p',
                                  'lev' => 7,
                                  'elbereth' => 1,
                                  'mr' => 10,
                                  'glyph' => 'Q'
                                },
          'wood golem' => {
                            'atk' => '3d4',
                            'spd' => 3,
                            'ac' => 4,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 900,
                                          'nutrition' => 0
                                        },
                            'res' => 'sp',
                            'lev' => 7,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => '\''
                          },
          'owlbear' => {
                         'atk' => '1d6 1d6 H2d8',
                         'spd' => 12,
                         'ac' => 5,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1700,
                                       'nutrition' => 700
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 1,
                         'mr' => 0,
                         'glyph' => 'Y'
                       },
          'water troll' => {
                             'atk' => '2W2d8 2d8 2d6',
                             'spd' => 14,
                             'ac' => 4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1200,
                                           'nutrition' => 350
                                         },
                             'res' => ' ',
                             'lev' => 11,
                             'elbereth' => 1,
                             'mr' => 40,
                             'glyph' => 'T'
                           },
          'homunculus' => {
                            'atk' => '1d3S',
                            'spd' => 12,
                            'ac' => 6,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 60,
                                          'nutrition' => 100
                                        },
                            'res' => 'SP',
                            'lev' => 2,
                            'elbereth' => 1,
                            'mr' => 10,
                            'glyph' => 'i'
                          },
          'warhorse' => {
                          'atk' => '1d10 1d4',
                          'spd' => 24,
                          'ac' => 4,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1800,
                                        'nutrition' => 350
                                      },
                          'res' => ' ',
                          'lev' => 7,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'u'
                        },
          'monk' => {
                      'atk' => '1d8 1d8',
                      'spd' => 12,
                      'ac' => 10,
                      'corpse' => {
                                    'cannibal' => 'Hum',
                                    'weight' => 1450,
                                    'nutrition' => 400
                                  },
                      'res' => ' ',
                      'lev' => 10,
                      'elbereth' => 0,
                      'mr' => 2,
                      'glyph' => '@'
                    },
          'water moccasin' => {
                                'atk' => '1d6P',
                                'spd' => 15,
                                'ac' => 3,
                                'corpse' => {
                                              'poison' => '27',
                                              'cannibal' => 0,
                                              'weight' => 150,
                                              'poisonous' => 1,
                                              'nutrition' => 80
                                            },
                                'res' => 'P',
                                'lev' => 4,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'S'
                              },
          'hill orc' => {
                          'atk' => 'W1d6',
                          'spd' => 9,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1000,
                                        'nutrition' => 200
                                      },
                          'res' => ' ',
                          'lev' => 2,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'o'
                        },
          'priestess' => {
                           'atk' => 'W1d6',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 10,
                           'elbereth' => 0,
                           'mr' => 2,
                           'glyph' => '@'
                         },
          'small mimic' => {
                             'atk' => '3d4',
                             'spd' => 3,
                             'ac' => 7,
                             'corpse' => {
                                           'mimic' => '20',
                                           'cannibal' => 0,
                                           'weight' => 300,
                                           'nutrition' => 200
                                         },
                             'res' => 'a',
                             'lev' => 7,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'm'
                           },
          'tiger' => {
                       'atk' => '2d4 2d4 1d10',
                       'spd' => 12,
                       'ac' => 6,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 600,
                                     'nutrition' => 300
                                   },
                       'res' => ' ',
                       'lev' => 6,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'f'
                     },
          'Lord Surtur' => {
                             'atk' => 'W2d10 W2d10 2d6-',
                             'spd' => 12,
                             'ac' => 2,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'fire' => '50',
                                           'weight' => 2250,
                                           'nutrition' => 850,
                                           'strength' => 1
                                         },
                             'res' => 'F*',
                             'lev' => 15,
                             'elbereth' => 1,
                             'mr' => 50,
                             'glyph' => 'H'
                           },
          'kobold lord' => {
                             'atk' => 'W2d4',
                             'spd' => 6,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 500,
                                           'poisonous' => 1,
                                           'nutrition' => 200
                                         },
                             'res' => 'p',
                             'lev' => 2,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'k'
                           },
          'werejackal' => {
                            'atk' => 'W2d4',
                            'spd' => 12,
                            'ac' => 10,
                            'corpse' => {
                                          'lycanthropy' => '100',
                                          'cannibal' => 'Hum',
                                          'weight' => 1450,
                                          'poisonous' => 1,
                                          'nutrition' => 400
                                        },
                            'res' => 'p',
                            'lev' => 2,
                            'elbereth' => 0,
                            'mr' => 10,
                            'glyph' => '@'
                          },
          'cobra' => {
                       'atk' => '2d4P S0d0b',
                       'spd' => 18,
                       'ac' => 2,
                       'corpse' => {
                                     'poison' => '40',
                                     'cannibal' => 0,
                                     'weight' => 250,
                                     'poisonous' => 1,
                                     'nutrition' => 100
                                   },
                       'res' => 'P',
                       'lev' => 6,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'S'
                     },
          'rock piercer' => {
                              'atk' => '2d6',
                              'spd' => 1,
                              'ac' => 3,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 200,
                                            'nutrition' => 200
                                          },
                              'res' => ' ',
                              'lev' => 3,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'p'
                            },
          'titan' => {
                       'atk' => 'W2d8 M0d0+',
                       'spd' => 18,
                       'ac' => -3,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 2300,
                                     'nutrition' => 900
                                   },
                       'res' => ' ',
                       'lev' => 16,
                       'elbereth' => 1,
                       'mr' => 70,
                       'glyph' => 'H'
                     },
          'white dragon' => {
                              'atk' => 'B4d6C 3d8 1d4 1d4',
                              'spd' => 9,
                              'ac' => -1,
                              'corpse' => {
                                            'cold' => '100',
                                            'cannibal' => 0,
                                            'weight' => 4500,
                                            'nutrition' => 1500
                                          },
                              'res' => 'C',
                              'lev' => 15,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'D'
                            },
          'brown pudding' => {
                               'atk' => '0d0r',
                               'spd' => 3,
                               'ac' => 8,
                               'corpse' => {
                                             'poison' => '11',
                                             'cold' => '11',
                                             'shock' => '11',
                                             'nutrition' => 250,
                                             'cannibal' => 0,
                                             'weight' => 500,
                                             'acidic' => 1
                                           },
                               'res' => 'CEPa*',
                               'lev' => 5,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'P'
                             },
          'gnome' => {
                       'atk' => 'W1d6',
                       'spd' => 6,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 'Gno',
                                     'weight' => 650,
                                     'nutrition' => 100
                                   },
                       'res' => ' ',
                       'lev' => 1,
                       'elbereth' => 1,
                       'mr' => 4,
                       'glyph' => 'G'
                     },
          'warrior' => {
                         'atk' => 'W1d8 W1d8',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 0,
                         'mr' => 10,
                         'glyph' => '@'
                       },
          'electric eel' => {
                              'atk' => '4d6E 0d0w',
                              'spd' => 10,
                              'ac' => -3,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'shock' => '47',
                                            'weight' => 200,
                                            'nutrition' => 250
                                          },
                              'res' => 'E',
                              'lev' => 7,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => ';'
                            },
          'stone golem' => {
                             'atk' => '3d8',
                             'spd' => 6,
                             'ac' => 5,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1900,
                                           'nutrition' => 0
                                         },
                             'res' => 'sp*',
                             'lev' => 14,
                             'elbereth' => 1,
                             'mr' => 50,
                             'glyph' => '\''
                           },
          'storm giant' => {
                             'atk' => 'W2d12',
                             'spd' => 12,
                             'ac' => 3,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'shock' => '50',
                                           'weight' => 2250,
                                           'nutrition' => 750,
                                           'strength' => 1
                                         },
                             'res' => 'E',
                             'lev' => 16,
                             'elbereth' => 1,
                             'mr' => 10,
                             'glyph' => 'H'
                           },
          'gold golem' => {
                            'atk' => '2d3 2d3',
                            'spd' => 9,
                            'ac' => 6,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 450,
                                          'nutrition' => 0
                                        },
                            'res' => 'spa',
                            'lev' => 5,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => '\''
                          },
          'hunter' => {
                        'atk' => 'W1d4',
                        'spd' => 12,
                        'ac' => 10,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => ' ',
                        'lev' => 5,
                        'elbereth' => 0,
                        'mr' => 10,
                        'glyph' => '@'
                      },
          'zruty' => {
                       'atk' => '3d4 3d4 3d6',
                       'spd' => 8,
                       'ac' => 3,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1200,
                                     'nutrition' => 600
                                   },
                       'res' => ' ',
                       'lev' => 9,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'z'
                     },
          'sasquatch' => {
                           'atk' => '1d6 1d6 1d8',
                           'spd' => 15,
                           'ac' => 6,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1550,
                                         'nutrition' => 750
                                       },
                           'res' => ' ',
                           'lev' => 7,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'Y'
                         },
          'jaguar' => {
                        'atk' => '1d4 1d4 1d8',
                        'spd' => 15,
                        'ac' => 6,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 600,
                                      'nutrition' => 300
                                    },
                        'res' => ' ',
                        'lev' => 4,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'f'
                      },
          'nurse' => {
                       'atk' => '2d6H',
                       'spd' => 6,
                       'ac' => 0,
                       'corpse' => {
                                     'poison' => '73',
                                     'cannibal' => 'Hum',
                                     'heal' => 1,
                                     'weight' => 1450,
                                     'nutrition' => 400
                                   },
                       'res' => 'P',
                       'lev' => 11,
                       'elbereth' => 0,
                       'mr' => 0,
                       'glyph' => '@'
                     },
          'Grand Master' => {
                              'atk' => '4d10 2d8 M2d8+ M2d8+',
                              'spd' => 12,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 400
                                          },
                              'res' => 'fsep',
                              'lev' => 25,
                              'elbereth' => 0,
                              'mr' => 70,
                              'glyph' => '@'
                            },
          'ranger' => {
                        'atk' => 'W1d4',
                        'spd' => 12,
                        'ac' => 10,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => ' ',
                        'lev' => 10,
                        'elbereth' => 0,
                        'mr' => 2,
                        'glyph' => '@'
                      },
          'stalker' => {
                         'atk' => '4d4',
                         'spd' => 12,
                         'ac' => 3,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'invisibility' => 1,
                                       'weight' => 900,
                                       'stun' => '60',
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 8,
                         'elbereth' => 1,
                         'mr' => 0,
                         'glyph' => 'E'
                       },
          'soldier ant' => {
                             'atk' => '2d4 3d4P',
                             'spd' => 18,
                             'ac' => 3,
                             'corpse' => {
                                           'poison' => '20',
                                           'cannibal' => 0,
                                           'weight' => 20,
                                           'poisonous' => 1,
                                           'nutrition' => 5
                                         },
                             'res' => 'P',
                             'lev' => 3,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'a'
                           },
          'titanothere' => {
                             'atk' => '2d8',
                             'spd' => 12,
                             'ac' => 6,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 2650,
                                           'nutrition' => 650
                                         },
                             'res' => ' ',
                             'lev' => 12,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'q'
                           },
          'jabberwock' => {
                            'atk' => '2d10 2d10 2d10 2d10',
                            'spd' => 12,
                            'ac' => -2,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1300,
                                          'nutrition' => 600
                                        },
                            'res' => ' ',
                            'lev' => 15,
                            'elbereth' => 1,
                            'mr' => 50,
                            'glyph' => 'J'
                          },
          'archeologist' => {
                              'atk' => 'W1d6 W1d6',
                              'spd' => 12,
                              'ac' => 10,
                              'corpse' => {
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 400
                                          },
                              'res' => ' ',
                              'lev' => 10,
                              'elbereth' => 0,
                              'mr' => 1,
                              'glyph' => '@'
                            },
          'baby crocodile' => {
                                'atk' => '1d4',
                                'spd' => 6,
                                'ac' => 7,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 200,
                                              'nutrition' => 200
                                            },
                                'res' => ' ',
                                'lev' => 3,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => ':'
                              },
          'glass piercer' => {
                               'atk' => '4d6',
                               'spd' => 1,
                               'ac' => 0,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 400,
                                             'nutrition' => 300
                                           },
                               'res' => 'a',
                               'lev' => 7,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'p'
                             },
          'watchman' => {
                          'atk' => 'W1d8',
                          'spd' => 10,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => ' ',
                          'lev' => 6,
                          'elbereth' => 0,
                          'mr' => 0,
                          'glyph' => '@'
                        },
          'stone giant' => {
                             'atk' => 'W2d10',
                             'spd' => 6,
                             'ac' => 0,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 2250,
                                           'nutrition' => 750,
                                           'strength' => 1
                                         },
                             'res' => ' ',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'H'
                           },
          'gremlin' => {
                         'atk' => '1d6 1d6 1d4 0d0i',
                         'spd' => 12,
                         'ac' => 2,
                         'corpse' => {
                                       'poison' => '33',
                                       'cannibal' => 0,
                                       'weight' => 100,
                                       'poisonous' => 1,
                                       'nutrition' => 20
                                     },
                         'res' => 'P',
                         'lev' => 5,
                         'elbereth' => 1,
                         'mr' => 25,
                         'glyph' => 'g'
                       },
          'black dragon' => {
                              'atk' => 'B4d10D 3d8 1d4 1d4',
                              'spd' => 9,
                              'ac' => -1,
                              'corpse' => {
                                            'disintegration' => '100',
                                            'cannibal' => 0,
                                            'weight' => 4500,
                                            'nutrition' => 1500
                                          },
                              'res' => 'D',
                              'lev' => 15,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'D'
                            },
          'Nalzok' => {
                        'atk' => 'W8d4 W4d6 M0d0+ 2d6-',
                        'spd' => 12,
                        'ac' => -2,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1450,
                                      'nutrition' => 0
                                    },
                        'res' => 'fp*',
                        'lev' => 16,
                        'elbereth' => 1,
                        'mr' => 85,
                        'glyph' => '&'
                      },
          'elf' => {
                     'atk' => 'W1d8',
                     'spd' => 12,
                     'ac' => 10,
                     'corpse' => {
                                   'cannibal' => 'Elf',
                                   'weight' => 800,
                                   'nutrition' => 350,
                                   'sleep' => '67'
                                 },
                     'res' => 'S',
                     'lev' => 10,
                     'elbereth' => 0,
                     'mr' => 2,
                     'glyph' => '@'
                   },
          'giant spider' => {
                              'atk' => '2d4P',
                              'spd' => 15,
                              'ac' => 4,
                              'corpse' => {
                                            'poison' => '33',
                                            'cannibal' => 0,
                                            'weight' => 100,
                                            'poisonous' => 1,
                                            'nutrition' => 100
                                          },
                              'res' => 'P',
                              'lev' => 5,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 's'
                            },
          'crocodile' => {
                           'atk' => '4d2 1d12',
                           'spd' => 9,
                           'ac' => 5,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 6,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => ':'
                         },
          'Green-elf' => {
                           'atk' => 'W2d4',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Elf',
                                         'weight' => 800,
                                         'nutrition' => 350,
                                         'sleep' => '33'
                                       },
                           'res' => 'S',
                           'lev' => 5,
                           'elbereth' => 0,
                           'mr' => 10,
                           'glyph' => '@'
                         },
          'Woodland-elf' => {
                              'atk' => 'W2d4',
                              'spd' => 12,
                              'ac' => 10,
                              'corpse' => {
                                            'cannibal' => 'Elf',
                                            'weight' => 800,
                                            'nutrition' => 350,
                                            'sleep' => '27'
                                          },
                              'res' => 'S',
                              'lev' => 4,
                              'elbereth' => 0,
                              'mr' => 10,
                              'glyph' => '@'
                            },
          'flesh golem' => {
                             'atk' => '2d8 2d8',
                             'spd' => 8,
                             'ac' => 9,
                             'corpse' => {
                                           'poison' => '12',
                                           'cold' => '12',
                                           'shock' => '12',
                                           'nutrition' => 600,
                                           'cannibal' => 0,
                                           'fire' => '12',
                                           'weight' => 1400,
                                           'sleep' => '12'
                                         },
                             'res' => 'FCSEP',
                             'lev' => 9,
                             'elbereth' => 1,
                             'mr' => 30,
                             'glyph' => '\''
                           },
          'Kop Sergeant' => {
                              'atk' => 'W1d6',
                              'spd' => 8,
                              'ac' => 10,
                              'corpse' => {
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 200
                                          },
                              'res' => ' ',
                              'lev' => 2,
                              'elbereth' => 1,
                              'mr' => 10,
                              'glyph' => 'K'
                            },
          'King Arthur' => {
                             'atk' => 'W1d6 W1d6',
                             'spd' => 12,
                             'ac' => 0,
                             'corpse' => {
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => ' ',
                             'lev' => 20,
                             'elbereth' => 0,
                             'mr' => 40,
                             'glyph' => '@'
                           },
          'attendant' => {
                           'atk' => 'W1d6',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => 'p',
                           'lev' => 5,
                           'elbereth' => 0,
                           'mr' => 10,
                           'glyph' => '@'
                         },
          'Ashikaga Takauji' => {
                                  'atk' => 'W2d6 W2d6 2d6-',
                                  'spd' => 12,
                                  'ac' => 0,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 1450,
                                                'nutrition' => 0
                                              },
                                  'res' => '*',
                                  'lev' => 15,
                                  'elbereth' => 0,
                                  'mr' => 40,
                                  'glyph' => '@'
                                },
          'flaming sphere' => {
                                'atk' => 'X4d6F',
                                'spd' => 13,
                                'ac' => 4,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 10,
                                              'nutrition' => 0
                                            },
                                'res' => 'F',
                                'lev' => 6,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'e'
                              },
          'kobold shaman' => {
                               'atk' => 'M0d0+',
                               'spd' => 6,
                               'ac' => 6,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 450,
                                             'poisonous' => 1,
                                             'nutrition' => 150
                                           },
                               'res' => 'p',
                               'lev' => 2,
                               'elbereth' => 1,
                               'mr' => 10,
                               'glyph' => 'k'
                             },
          'energy vortex' => {
                               'atk' => 'E1d6E E0d0e (0d4E)',
                               'spd' => 20,
                               'ac' => 2,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 0,
                                             'nutrition' => 0
                                           },
                               'res' => 'sdep*',
                               'lev' => 6,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'v'
                             },
          'gnomish wizard' => {
                                'atk' => 'M0d0+',
                                'spd' => 10,
                                'ac' => 4,
                                'corpse' => {
                                              'cannibal' => 'Gno',
                                              'weight' => 700,
                                              'nutrition' => 120
                                            },
                                'res' => ' ',
                                'lev' => 3,
                                'elbereth' => 1,
                                'mr' => 10,
                                'glyph' => 'G'
                              },
          'gnome mummy' => {
                             'atk' => '1d6',
                             'spd' => 10,
                             'ac' => 6,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 650,
                                           'nutrition' => 50
                                         },
                             'res' => 'csp',
                             'lev' => 4,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'M'
                           },
          'hell hound' => {
                            'atk' => '3d6 B3d6F',
                            'spd' => 14,
                            'ac' => 2,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'fire' => '80',
                                          'weight' => 600,
                                          'nutrition' => 300
                                        },
                            'res' => 'F',
                            'lev' => 12,
                            'elbereth' => 1,
                            'mr' => 20,
                            'glyph' => 'd'
                          },
          'leprechaun' => {
                            'atk' => '1d2$',
                            'spd' => 15,
                            'ac' => 8,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 60,
                                          'nutrition' => 30,
                                          'teleportitis' => '50'
                                        },
                            'res' => ' ',
                            'lev' => 5,
                            'elbereth' => 1,
                            'mr' => 20,
                            'glyph' => 'l'
                          },
          'orc shaman' => {
                            'atk' => 'M0d0+',
                            'spd' => 9,
                            'ac' => 5,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1000,
                                          'nutrition' => 300
                                        },
                            'res' => ' ',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 10,
                            'glyph' => 'o'
                          },
          'manes' => {
                       'atk' => '1d3 1d3 1d4',
                       'spd' => 3,
                       'ac' => 7,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 100,
                                     'nutrition' => 0
                                   },
                       'res' => 'sp',
                       'lev' => 1,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'i'
                     },
          'orc-captain' => {
                             'atk' => 'W2d4 W2d4',
                             'spd' => 5,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1350,
                                           'nutrition' => 350
                                         },
                             'res' => ' ',
                             'lev' => 5,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'o'
                           },
          'dwarf king' => {
                            'atk' => 'W2d6 W2d6',
                            'spd' => 6,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 'Dwa',
                                          'weight' => 900,
                                          'nutrition' => 300
                                        },
                            'res' => ' ',
                            'lev' => 6,
                            'elbereth' => 1,
                            'mr' => 20,
                            'glyph' => 'h'
                          },
          'wererat' => {
                         'atk' => 'W2d4',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'lycanthropy' => '100',
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'poisonous' => 1,
                                       'nutrition' => 400
                                     },
                         'res' => 'p',
                         'lev' => 2,
                         'elbereth' => 0,
                         'mr' => 10,
                         'glyph' => '@'
                       },
          'plains centaur' => {
                                'atk' => 'W1d6 1d6',
                                'spd' => 18,
                                'ac' => 4,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 2500,
                                              'nutrition' => 500
                                            },
                                'res' => ' ',
                                'lev' => 4,
                                'elbereth' => 1,
                                'mr' => 0,
                                'glyph' => 'C'
                              },
          'ice devil' => {
                           'atk' => '1d4 1d4 2d4 3d4C',
                           'spd' => 6,
                           'ac' => -4,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1450,
                                         'nutrition' => 0
                                       },
                           'res' => 'fcp',
                           'lev' => 11,
                           'elbereth' => 1,
                           'mr' => 55,
                           'glyph' => '&'
                         },
          'lynx' => {
                      'atk' => '1d4 1d4 1d10',
                      'spd' => 15,
                      'ac' => 6,
                      'corpse' => {
                                    'cannibal' => 0,
                                    'weight' => 600,
                                    'nutrition' => 300
                                  },
                      'res' => ' ',
                      'lev' => 5,
                      'elbereth' => 1,
                      'mr' => 0,
                      'glyph' => 'f'
                    },
          'jackal' => {
                        'atk' => '1d2',
                        'spd' => 12,
                        'ac' => 7,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 300,
                                      'nutrition' => 250
                                    },
                        'res' => ' ',
                        'lev' => 0,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'd'
                      },
          'Aleax' => {
                       'atk' => 'W1d6 W1d6 1d4',
                       'spd' => 8,
                       'ac' => 0,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1450,
                                     'nutrition' => 0
                                   },
                       'res' => 'csep',
                       'lev' => 10,
                       'elbereth' => 0,
                       'mr' => 30,
                       'glyph' => 'A'
                     },
          'thug' => {
                      'atk' => 'W1d6 W1d6',
                      'spd' => 12,
                      'ac' => 10,
                      'corpse' => {
                                    'cannibal' => 'Hum',
                                    'weight' => 1450,
                                    'nutrition' => 400
                                  },
                      'res' => ' ',
                      'lev' => 5,
                      'elbereth' => 0,
                      'mr' => 10,
                      'glyph' => '@'
                    },
          'green dragon' => {
                              'atk' => 'B4d6P 3d8 1d4 1d4',
                              'spd' => 9,
                              'ac' => -1,
                              'corpse' => {
                                            'poison' => '100',
                                            'cannibal' => 0,
                                            'weight' => 4500,
                                            'poisonous' => 1,
                                            'nutrition' => 1500
                                          },
                              'res' => 'P',
                              'lev' => 15,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'D'
                            },
          'ettin mummy' => {
                             'atk' => '2d6 2d6',
                             'spd' => 12,
                             'ac' => 4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1700,
                                           'nutrition' => 250
                                         },
                             'res' => 'csp',
                             'lev' => 7,
                             'elbereth' => 1,
                             'mr' => 30,
                             'glyph' => 'M'
                           },
          'Pelias' => {
                        'atk' => 'W1d6',
                        'spd' => 12,
                        'ac' => 0,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => 'p',
                        'lev' => 20,
                        'elbereth' => 0,
                        'mr' => 30,
                        'glyph' => '@'
                      },
          'ice troll' => {
                           'atk' => 'W2d6 2d6C 2d6',
                           'spd' => 10,
                           'ac' => 2,
                           'corpse' => {
                                         'cold' => '60',
                                         'cannibal' => 0,
                                         'weight' => 1000,
                                         'nutrition' => 300
                                       },
                           'res' => 'C',
                           'lev' => 9,
                           'elbereth' => 1,
                           'mr' => 20,
                           'glyph' => 'T'
                         },
          'ochre jelly' => {
                             'atk' => 'E3d6A (3d6A)',
                             'spd' => 3,
                             'ac' => 8,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 50,
                                           'nutrition' => 20,
                                           'acidic' => 1
                                         },
                             'res' => 'a*',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'j'
                           },
          'monkey' => {
                        'atk' => '0d0- 1d3',
                        'spd' => 12,
                        'ac' => 6,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 100,
                                      'nutrition' => 50
                                    },
                        'res' => ' ',
                        'lev' => 2,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'Y'
                      },
          'vampire bat' => {
                             'atk' => '1d6 0d0P',
                             'spd' => 20,
                             'ac' => 6,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 30,
                                           'poisonous' => 1,
                                           'nutrition' => 20
                                         },
                             'res' => 'sp',
                             'lev' => 5,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'B'
                           },
          'Orcus' => {
                       'atk' => 'W3d6 3d4 3d4 M8d6+ 2d4P',
                       'spd' => 9,
                       'ac' => -6,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1500,
                                     'nutrition' => 0
                                   },
                       'res' => 'fp',
                       'lev' => 66,
                       'elbereth' => 1,
                       'mr' => 85,
                       'glyph' => '&'
                     },
          'master mind flayer' => {
                                    'atk' => 'W1d8 2!I 2!I 2!I 2!I 2!I',
                                    'spd' => 12,
                                    'ac' => 0,
                                    'corpse' => {
                                                  'intelligence' => '50',
                                                  'cannibal' => 0,
                                                  'weight' => 1450,
                                                  'nutrition' => 400,
                                                  'telepathy' => 1
                                                },
                                    'res' => ' ',
                                    'lev' => 13,
                                    'elbereth' => 1,
                                    'mr' => 90,
                                    'glyph' => 'h'
                                  },
          'air elemental' => {
                               'atk' => 'E1d10',
                               'spd' => 36,
                               'ac' => 2,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 0,
                                             'nutrition' => 0
                                           },
                               'res' => 'p*',
                               'lev' => 8,
                               'elbereth' => 1,
                               'mr' => 30,
                               'glyph' => 'E'
                             },
          'gargoyle' => {
                          'atk' => '2d6 2d6 2d4',
                          'spd' => 10,
                          'ac' => -4,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1000,
                                        'nutrition' => 200
                                      },
                          'res' => '*',
                          'lev' => 6,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'g'
                        },
          'kobold zombie' => {
                               'atk' => '1d4',
                               'spd' => 6,
                               'ac' => 10,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 400,
                                             'nutrition' => 50
                                           },
                               'res' => 'csp',
                               'lev' => 0,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'Z'
                             },
          'ogre lord' => {
                           'atk' => 'W2d6',
                           'spd' => 12,
                           'ac' => 3,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1700,
                                         'nutrition' => 700
                                       },
                           'res' => ' ',
                           'lev' => 7,
                           'elbereth' => 1,
                           'mr' => 30,
                           'glyph' => 'O'
                         },
          'Medusa' => {
                        'atk' => 'W2d4 1d8 G0d0* 1d6P',
                        'spd' => 12,
                        'ac' => 2,
                        'corpse' => {
                                      'poison' => '100',
                                      'petrify' => 1,
                                      'poisonous' => 1,
                                      'nutrition' => 400,
                                      'cannibal' => 0,
                                      'weight' => 1450
                                    },
                        'res' => 'P*',
                        'lev' => 20,
                        'elbereth' => 0,
                        'mr' => 50,
                        'glyph' => '@'
                      },
          'Yeenoghu' => {
                          'atk' => 'W3d6 W2d8c W1d6. M2d6M',
                          'spd' => 18,
                          'ac' => -5,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 900,
                                        'nutrition' => 0
                                      },
                          'res' => 'fp',
                          'lev' => 56,
                          'elbereth' => 1,
                          'mr' => 80,
                          'glyph' => '&'
                        },
          'baby black dragon' => {
                                   'atk' => '2d6',
                                   'spd' => 9,
                                   'ac' => 2,
                                   'corpse' => {
                                                 'cannibal' => 0,
                                                 'weight' => 1500,
                                                 'nutrition' => 500
                                               },
                                   'res' => 'd',
                                   'lev' => 12,
                                   'elbereth' => 1,
                                   'mr' => 10,
                                   'glyph' => 'D'
                                 },
          'Vlad the Impaler' => {
                                  'atk' => 'W1d10 1d10V',
                                  'spd' => 18,
                                  'ac' => -3,
                                  'corpse' => {
                                                'cannibal' => 0,
                                                'weight' => 1450,
                                                'nutrition' => 0
                                              },
                                  'res' => 'sp',
                                  'lev' => 14,
                                  'elbereth' => 1,
                                  'mr' => 80,
                                  'glyph' => 'V'
                                },
          'incubus' => {
                         'atk' => '0d0&amp; 1d3 1d3',
                         'spd' => 12,
                         'ac' => 0,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1450,
                                       'nutrition' => 0
                                     },
                         'res' => 'fp',
                         'lev' => 6,
                         'elbereth' => 1,
                         'mr' => 70,
                         'glyph' => '&'
                       },
          'killer bee' => {
                            'atk' => '1d3P',
                            'spd' => 18,
                            'ac' => -1,
                            'corpse' => {
                                          'poison' => '30',
                                          'cannibal' => 0,
                                          'weight' => 1,
                                          'poisonous' => 1,
                                          'nutrition' => 5
                                        },
                            'res' => 'P',
                            'lev' => 1,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'a'
                          },
          'ghost' => {
                       'atk' => '1d1',
                       'spd' => 3,
                       'ac' => -5,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1450,
                                     'nutrition' => 0
                                   },
                       'res' => 'csdp*',
                       'lev' => 10,
                       'elbereth' => 1,
                       'mr' => 50,
                       'glyph' => 'X'
                     },
          'raven' => {
                       'atk' => '1d6 1d6b',
                       'spd' => 20,
                       'ac' => 6,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 40,
                                     'nutrition' => 20
                                   },
                       'res' => ' ',
                       'lev' => 4,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'B'
                     },
          'Famine' => {
                        'atk' => '8d8z 8d8z',
                        'spd' => 12,
                        'ac' => -5,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1450,
                                      'die' => 1,
                                      'nutrition' => 1
                                    },
                        'res' => 'fcsep*',
                        'lev' => 30,
                        'elbereth' => 0,
                        'mr' => 100,
                        'glyph' => '&'
                      },
          'green slime' => {
                             'atk' => '1d4@ (0d0@)',
                             'spd' => 6,
                             'ac' => 6,
                             'corpse' => {
                                           'slime' => 1,
                                           'poisonous' => 1,
                                           'nutrition' => 150,
                                           'cannibal' => 0,
                                           'weight' => 400,
                                           'acidic' => 1
                                         },
                             'res' => 'cepa*',
                             'lev' => 6,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 'P'
                           },
          'lieutenant' => {
                            'atk' => 'W3d4 W3d4',
                            'spd' => 10,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 'Hum',
                                          'weight' => 1450,
                                          'nutrition' => 400
                                        },
                            'res' => ' ',
                            'lev' => 10,
                            'elbereth' => 0,
                            'mr' => 15,
                            'glyph' => '@'
                          },
          'grid bug' => {
                          'atk' => '1d1E',
                          'spd' => 12,
                          'ac' => 9,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 15,
                                        'nutrition' => 0
                                      },
                          'res' => 'ep',
                          'lev' => 0,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'x'
                        },
          'pit viper' => {
                           'atk' => '1d4P 1d4P',
                           'spd' => 15,
                           'ac' => 2,
                           'corpse' => {
                                         'poison' => '40',
                                         'cannibal' => 0,
                                         'weight' => 100,
                                         'poisonous' => 1,
                                         'nutrition' => 60
                                       },
                           'res' => 'P',
                           'lev' => 6,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'S'
                         },
          'iguana' => {
                        'atk' => '1d4',
                        'spd' => 6,
                        'ac' => 7,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 30,
                                      'nutrition' => 30
                                    },
                        'res' => ' ',
                        'lev' => 2,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => ':'
                      },
          'dog' => {
                     'atk' => '1d6',
                     'spd' => 16,
                     'ac' => 5,
                     'corpse' => {
                                   'aggravate' => 1,
                                   'cannibal' => 0,
                                   'weight' => 400,
                                   'nutrition' => 200
                                 },
                     'res' => ' ',
                     'lev' => 4,
                     'elbereth' => 1,
                     'mr' => 0,
                     'glyph' => 'd'
                   },
          'water nymph' => {
                             'atk' => '0d0- 0d0-',
                             'spd' => 12,
                             'ac' => 9,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 600,
                                           'nutrition' => 300,
                                           'teleportitis' => '30'
                                         },
                             'res' => ' ',
                             'lev' => 3,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'n'
                           },
          'housecat' => {
                          'atk' => '1d6',
                          'spd' => 16,
                          'ac' => 5,
                          'corpse' => {
                                        'aggravate' => 1,
                                        'cannibal' => 0,
                                        'weight' => 200,
                                        'nutrition' => 200
                                      },
                          'res' => ' ',
                          'lev' => 4,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'f'
                        },
          'Chromatic Dragon' => {
                                  'atk' => 'B6d8z M0d0+ 2d8- 4d8 4d8 1d6',
                                  'spd' => 12,
                                  'ac' => 0,
                                  'corpse' => {
                                                'poison' => '17',
                                                'cold' => '17',
                                                'shock' => '17',
                                                'poisonous' => 1,
                                                'nutrition' => 1700,
                                                'disintegration' => '17',
                                                'cannibal' => 0,
                                                'fire' => '17',
                                                'weight' => 4500,
                                                'sleep' => '17'
                                              },
                                  'res' => 'FCSDEPa*',
                                  'lev' => 16,
                                  'elbereth' => 1,
                                  'mr' => 30,
                                  'glyph' => 'D'
                                },
          'orc zombie' => {
                            'atk' => '1d6',
                            'spd' => 6,
                            'ac' => 9,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 850,
                                          'nutrition' => 75
                                        },
                            'res' => 'csp',
                            'lev' => 2,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'Z'
                          },
          'Grey-elf' => {
                          'atk' => 'W2d4',
                          'spd' => 12,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Elf',
                                        'weight' => 800,
                                        'nutrition' => 350,
                                        'sleep' => '40'
                                      },
                          'res' => 'S',
                          'lev' => 6,
                          'elbereth' => 0,
                          'mr' => 10,
                          'glyph' => '@'
                        },
          'Archon' => {
                        'atk' => 'W2d4 W2d4 G2d6b 1d8 M4d6+',
                        'spd' => 16,
                        'ac' => -6,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1450,
                                      'nutrition' => 0
                                    },
                        'res' => 'fcsep',
                        'lev' => 19,
                        'elbereth' => 0,
                        'mr' => 80,
                        'glyph' => 'A'
                      },
          'djinni' => {
                        'atk' => 'W2d8',
                        'spd' => 12,
                        'ac' => 4,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1500,
                                      'nutrition' => 0
                                    },
                        'res' => 'p*',
                        'lev' => 7,
                        'elbereth' => 1,
                        'mr' => 30,
                        'glyph' => '&'
                      },
          'white unicorn' => {
                               'atk' => '1d12 1d6',
                               'spd' => 24,
                               'ac' => 2,
                               'corpse' => {
                                             'poison' => '27',
                                             'cannibal' => 0,
                                             'weight' => 1300,
                                             'nutrition' => 300
                                           },
                               'res' => 'P',
                               'lev' => 4,
                               'elbereth' => 1,
                               'mr' => 70,
                               'glyph' => 'u'
                             },
          'horse' => {
                       'atk' => '1d8 1d3',
                       'spd' => 20,
                       'ac' => 5,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1500,
                                     'nutrition' => 300
                                   },
                       'res' => ' ',
                       'lev' => 5,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'u'
                     },
          'coyote' => {
                        'atk' => '1d4',
                        'spd' => 12,
                        'ac' => 7,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 300,
                                      'nutrition' => 250
                                    },
                        'res' => ' ',
                        'lev' => 1,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'd'
                      },
          'mastodon' => {
                          'atk' => '4d8 4d8',
                          'spd' => 12,
                          'ac' => 5,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 3800,
                                        'nutrition' => 800
                                      },
                          'res' => ' ',
                          'lev' => 20,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'q'
                        },
          'vampire' => {
                         'atk' => '1d6 1d6V',
                         'spd' => 12,
                         'ac' => 1,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => 'sp',
                         'lev' => 10,
                         'elbereth' => 1,
                         'mr' => 25,
                         'glyph' => 'V'
                       },
          'red naga' => {
                          'atk' => '2d4 B2d6F',
                          'spd' => 12,
                          'ac' => 4,
                          'corpse' => {
                                        'poison' => '20',
                                        'cannibal' => 0,
                                        'fire' => '20',
                                        'weight' => 2600,
                                        'nutrition' => 400
                                      },
                          'res' => 'FP',
                          'lev' => 6,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 'N'
                        },
          'mind flayer' => {
                             'atk' => 'W1d4 2!I 2!I 2!I',
                             'spd' => 12,
                             'ac' => 5,
                             'corpse' => {
                                           'intelligence' => '50',
                                           'cannibal' => 0,
                                           'weight' => 1450,
                                           'nutrition' => 400,
                                           'telepathy' => 1
                                         },
                             'res' => ' ',
                             'lev' => 9,
                             'elbereth' => 1,
                             'mr' => 90,
                             'glyph' => 'h'
                           },
          'black unicorn' => {
                               'atk' => '1d12 1d6',
                               'spd' => 24,
                               'ac' => 2,
                               'corpse' => {
                                             'poison' => '27',
                                             'cannibal' => 0,
                                             'weight' => 1300,
                                             'nutrition' => 300
                                           },
                               'res' => 'P',
                               'lev' => 4,
                               'elbereth' => 1,
                               'mr' => 70,
                               'glyph' => 'u'
                             },
          'kraken' => {
                        'atk' => '2d4 2d4 H2d6w 5d4',
                        'spd' => 3,
                        'ac' => 6,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1800,
                                      'nutrition' => 1000
                                    },
                        'res' => ' ',
                        'lev' => 20,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => ';'
                      },
          'roshi' => {
                       'atk' => 'W1d8 W1d8',
                       'spd' => 12,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 'Hum',
                                     'weight' => 1450,
                                     'nutrition' => 400
                                   },
                       'res' => ' ',
                       'lev' => 5,
                       'elbereth' => 0,
                       'mr' => 10,
                       'glyph' => '@'
                     },
          'Wizard of Yendor' => {
                                  'atk' => '2d12- M0d0+',
                                  'spd' => 12,
                                  'ac' => -8,
                                  'corpse' => {
                                                'poison' => '25',
                                                'nutrition' => 400,
                                                'cannibal' => 'Hum',
                                                'teleport control' => '25',
                                                'fire' => '25',
                                                'weight' => 1450,
                                                'teleportitis' => '25'
                                              },
                                  'res' => 'FP',
                                  'lev' => 30,
                                  'elbereth' => 0,
                                  'mr' => 100,
                                  'glyph' => '@'
                                },
          'guide' => {
                       'atk' => 'W1d6 M0d0+',
                       'spd' => 12,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 'Hum',
                                     'weight' => 1450,
                                     'nutrition' => 400
                                   },
                       'res' => ' ',
                       'lev' => 5,
                       'elbereth' => 0,
                       'mr' => 20,
                       'glyph' => '@'
                     },
          'lurker above' => {
                              'atk' => 'E1d8d',
                              'spd' => 3,
                              'ac' => 3,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 800,
                                            'nutrition' => 350
                                          },
                              'res' => ' ',
                              'lev' => 10,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 't'
                            },
          'Master Assassin' => {
                                 'atk' => 'W2d6P W2d8 2d6-',
                                 'spd' => 12,
                                 'ac' => 0,
                                 'corpse' => {
                                               'cannibal' => 'Hum',
                                               'weight' => 1450,
                                               'nutrition' => 400
                                             },
                                 'res' => '*',
                                 'lev' => 15,
                                 'elbereth' => 0,
                                 'mr' => 30,
                                 'glyph' => '@'
                               },
          'healer' => {
                        'atk' => 'W1d6',
                        'spd' => 12,
                        'ac' => 10,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => 'p',
                        'lev' => 10,
                        'elbereth' => 0,
                        'mr' => 1,
                        'glyph' => '@'
                      },
          'Elvenking' => {
                           'atk' => 'W2d4 W2d4',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Elf',
                                         'weight' => 800,
                                         'nutrition' => 350,
                                         'sleep' => '60'
                                       },
                           'res' => 'S',
                           'lev' => 9,
                           'elbereth' => 0,
                           'mr' => 25,
                           'glyph' => '@'
                         },
          'cockatrice' => {
                            'atk' => '1d3 0d0* (0d0*)',
                            'spd' => 6,
                            'ac' => 6,
                            'corpse' => {
                                          'poison' => '33',
                                          'petrify' => 1,
                                          'cannibal' => 0,
                                          'weight' => 30,
                                          'nutrition' => 30
                                        },
                            'res' => 'P*',
                            'lev' => 5,
                            'elbereth' => 1,
                            'mr' => 30,
                            'glyph' => 'c'
                          },
          'carnivorous ape' => {
                                 'atk' => '1d4 1d4 H1d8',
                                 'spd' => 12,
                                 'ac' => 6,
                                 'corpse' => {
                                               'cannibal' => 0,
                                               'weight' => 1250,
                                               'nutrition' => 550
                                             },
                                 'res' => ' ',
                                 'lev' => 6,
                                 'elbereth' => 1,
                                 'mr' => 0,
                                 'glyph' => 'Y'
                               },
          'fire elemental' => {
                                'atk' => '3d6F (0d4F)',
                                'spd' => 12,
                                'ac' => 2,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'weight' => 0,
                                              'nutrition' => 0
                                            },
                                'res' => 'fp*',
                                'lev' => 8,
                                'elbereth' => 1,
                                'mr' => 30,
                                'glyph' => 'E'
                              },
          'jellyfish' => {
                           'atk' => '3d3P',
                           'spd' => 3,
                           'ac' => 6,
                           'corpse' => {
                                         'poison' => '20',
                                         'cannibal' => 0,
                                         'weight' => 80,
                                         'poisonous' => 1,
                                         'nutrition' => 20
                                       },
                           'res' => 'P',
                           'lev' => 3,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => ';'
                         },
          'demilich' => {
                          'atk' => '3d4C M0d0+',
                          'spd' => 9,
                          'ac' => -2,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1200,
                                        'nutrition' => 0
                                      },
                          'res' => 'Csp',
                          'lev' => 14,
                          'elbereth' => 1,
                          'mr' => 60,
                          'glyph' => 'L'
                        },
          'master lich' => {
                             'atk' => '3d6C M0d0+',
                             'spd' => 9,
                             'ac' => -4,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1200,
                                           'nutrition' => 0
                                         },
                             'res' => 'FCsp',
                             'lev' => 17,
                             'elbereth' => 1,
                             'mr' => 90,
                             'glyph' => 'L'
                           },
          'rogue' => {
                       'atk' => 'W1d6 W1d6',
                       'spd' => 12,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 'Hum',
                                     'weight' => 1450,
                                     'nutrition' => 400
                                   },
                       'res' => ' ',
                       'lev' => 10,
                       'elbereth' => 0,
                       'mr' => 1,
                       'glyph' => '@'
                     },
          'yellow dragon' => {
                               'atk' => 'B4d6A 3d8 1d4 1d4',
                               'spd' => 9,
                               'ac' => -1,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 4500,
                                             'nutrition' => 1500,
                                             'acidic' => 1
                                           },
                               'res' => 'a*',
                               'lev' => 15,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'D'
                             },
          'cave spider' => {
                             'atk' => '1d2',
                             'spd' => 12,
                             'ac' => 3,
                             'corpse' => {
                                           'poison' => '7',
                                           'cannibal' => 0,
                                           'weight' => 50,
                                           'nutrition' => 50
                                         },
                             'res' => 'P',
                             'lev' => 1,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => 's'
                           },
          'red dragon' => {
                            'atk' => 'B6d6F 3d8 1d4 1d4',
                            'spd' => 9,
                            'ac' => -1,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'fire' => '100',
                                          'weight' => 4500,
                                          'nutrition' => 1500
                                        },
                            'res' => 'F',
                            'lev' => 15,
                            'elbereth' => 1,
                            'mr' => 20,
                            'glyph' => 'D'
                          },
          'Ixoth' => {
                       'atk' => 'B8d6F 4d8 M0d0+ 2d4 2d4-',
                       'spd' => 12,
                       'ac' => -1,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'fire' => '100',
                                     'weight' => 4500,
                                     'nutrition' => 1600
                                   },
                       'res' => 'F*',
                       'lev' => 15,
                       'elbereth' => 1,
                       'mr' => 20,
                       'glyph' => 'D'
                     },
          'silver dragon' => {
                               'atk' => 'B4d6C 3d8 1d4 1d4',
                               'spd' => 9,
                               'ac' => -1,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 4500,
                                             'nutrition' => 1500
                                           },
                               'res' => 'c',
                               'lev' => 15,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'D'
                             },
          'iron piercer' => {
                              'atk' => '3d6',
                              'spd' => 1,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 400,
                                            'nutrition' => 300
                                          },
                              'res' => ' ',
                              'lev' => 5,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'p'
                            },
          'rabid rat' => {
                           'atk' => '2d4!C',
                           'spd' => 12,
                           'ac' => 6,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 30,
                                         'poisonous' => 1,
                                         'nutrition' => 5
                                       },
                           'res' => 'p',
                           'lev' => 2,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'r'
                         },
          'prisoner' => {
                          'atk' => 'W1d6',
                          'spd' => 12,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => ' ',
                          'lev' => 12,
                          'elbereth' => 0,
                          'mr' => 0,
                          'glyph' => '@'
                        },
          'garter snake' => {
                              'atk' => '1d2',
                              'spd' => 8,
                              'ac' => 8,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 50,
                                            'nutrition' => 60
                                          },
                              'res' => ' ',
                              'lev' => 1,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'S'
                            },
          'water elemental' => {
                                 'atk' => '5d6',
                                 'spd' => 6,
                                 'ac' => 2,
                                 'corpse' => {
                                               'cannibal' => 0,
                                               'weight' => 2500,
                                               'nutrition' => 0
                                             },
                                 'res' => 'p*',
                                 'lev' => 8,
                                 'elbereth' => 1,
                                 'mr' => 30,
                                 'glyph' => 'E'
                               },
          'Oracle' => {
                        'atk' => '(0d4M)',
                        'spd' => 0,
                        'ac' => 0,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => ' ',
                        'lev' => 12,
                        'elbereth' => 0,
                        'mr' => 50,
                        'glyph' => '@'
                      },
          'gecko' => {
                       'atk' => '1d3',
                       'spd' => 6,
                       'ac' => 8,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 10,
                                     'nutrition' => 20
                                   },
                       'res' => ' ',
                       'lev' => 1,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => ':'
                     },
          'high priest' => {
                             'atk' => 'W4d10 2d8 M2d8+ M2d8+',
                             'spd' => 15,
                             'ac' => 7,
                             'corpse' => {
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => 'fsep',
                             'lev' => 25,
                             'elbereth' => 0,
                             'mr' => 70,
                             'glyph' => '@'
                           },
          'barrow wight' => {
                              'atk' => 'W0d0V M0d0+ 1d4',
                              'spd' => 12,
                              'ac' => 5,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1200,
                                            'nutrition' => 0
                                          },
                              'res' => 'csp',
                              'lev' => 3,
                              'elbereth' => 1,
                              'mr' => 5,
                              'glyph' => 'W'
                            },
          'Asmodeus' => {
                          'atk' => '4d4 M6d6C',
                          'spd' => 12,
                          'ac' => -7,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1500,
                                        'nutrition' => 0
                                      },
                          'res' => 'fcp',
                          'lev' => 105,
                          'elbereth' => 1,
                          'mr' => 90,
                          'glyph' => '&'
                        },
          'gelatinous cube' => {
                                 'atk' => '2d4. (1d4.)',
                                 'spd' => 6,
                                 'ac' => 8,
                                 'corpse' => {
                                               'cold' => '10',
                                               'shock' => '10',
                                               'nutrition' => 150,
                                               'cannibal' => 0,
                                               'fire' => '10',
                                               'weight' => 600,
                                               'sleep' => '10',
                                               'acidic' => 1
                                             },
                                 'res' => 'FCSEpa*',
                                 'lev' => 6,
                                 'elbereth' => 1,
                                 'mr' => 0,
                                 'glyph' => 'b'
                               },
          'barbed devil' => {
                              'atk' => '2d4 2d4 3d4',
                              'spd' => 12,
                              'ac' => 0,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1450,
                                            'nutrition' => 0
                                          },
                              'res' => 'fp',
                              'lev' => 8,
                              'elbereth' => 1,
                              'mr' => 35,
                              'glyph' => '&'
                            },
          'hell hound pup' => {
                                'atk' => '2d6 B2d6F',
                                'spd' => 12,
                                'ac' => 4,
                                'corpse' => {
                                              'cannibal' => 0,
                                              'fire' => '47',
                                              'weight' => 200,
                                              'nutrition' => 200
                                            },
                                'res' => 'F',
                                'lev' => 7,
                                'elbereth' => 1,
                                'mr' => 20,
                                'glyph' => 'd'
                              },
          'Kop Lieutenant' => {
                                'atk' => 'W1d8',
                                'spd' => 10,
                                'ac' => 10,
                                'corpse' => {
                                              'cannibal' => 'Hum',
                                              'weight' => 1450,
                                              'nutrition' => 200
                                            },
                                'res' => ' ',
                                'lev' => 3,
                                'elbereth' => 1,
                                'mr' => 20,
                                'glyph' => 'K'
                              },
          'bugbear' => {
                         'atk' => 'W2d4',
                         'spd' => 9,
                         'ac' => 5,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 1250,
                                       'nutrition' => 250
                                     },
                         'res' => ' ',
                         'lev' => 3,
                         'elbereth' => 1,
                         'mr' => 0,
                         'glyph' => 'h'
                       },
          'earth elemental' => {
                                 'atk' => '4d6',
                                 'spd' => 6,
                                 'ac' => 2,
                                 'corpse' => {
                                               'cannibal' => 0,
                                               'weight' => 2500,
                                               'nutrition' => 0
                                             },
                                 'res' => 'fcp*',
                                 'lev' => 8,
                                 'elbereth' => 1,
                                 'mr' => 30,
                                 'glyph' => 'E'
                               },
          'lizard' => {
                        'atk' => '1d6',
                        'spd' => 6,
                        'ac' => 6,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 10,
                                      'nutrition' => 40
                                    },
                        'res' => '*',
                        'lev' => 5,
                        'elbereth' => 1,
                        'mr' => 10,
                        'glyph' => ':'
                      },
          'tengu' => {
                       'atk' => '1d7',
                       'spd' => 13,
                       'ac' => 5,
                       'corpse' => {
                                     'poison' => '13',
                                     'cannibal' => 0,
                                     'teleport control' => '17',
                                     'weight' => 300,
                                     'nutrition' => 200,
                                     'teleportitis' => '20'
                                   },
                       'res' => 'P',
                       'lev' => 6,
                       'elbereth' => 1,
                       'mr' => 30,
                       'glyph' => 'i'
                     },
          'sandestin' => {
                           'atk' => 'W2d6 W2d6',
                           'spd' => 12,
                           'ac' => 4,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 1500,
                                         'nutrition' => 0
                                       },
                           'res' => '*',
                           'lev' => 13,
                           'elbereth' => 1,
                           'mr' => 60,
                           'glyph' => '&'
                         },
          'Dispater' => {
                          'atk' => 'W4d6 M6d6+',
                          'spd' => 15,
                          'ac' => -2,
                          'corpse' => {
                                        'cannibal' => 0,
                                        'weight' => 1500,
                                        'nutrition' => 0
                                      },
                          'res' => 'fp',
                          'lev' => 78,
                          'elbereth' => 1,
                          'mr' => 80,
                          'glyph' => '&'
                        },
          'barbarian' => {
                           'atk' => 'W1d6 W1d6',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => 'p',
                           'lev' => 10,
                           'elbereth' => 0,
                           'mr' => 1,
                           'glyph' => '@'
                         },
          'Master Kaen' => {
                             'atk' => '16d2 16d2 M0d0+ 1d4-',
                             'spd' => 12,
                             'ac' => -10,
                             'corpse' => {
                                           'poison' => '100',
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => 'P*',
                             'lev' => 25,
                             'elbereth' => 0,
                             'mr' => 10,
                             'glyph' => '@'
                           },
          'Croesus' => {
                         'atk' => 'W4d10',
                         'spd' => 15,
                         'ac' => 0,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 20,
                         'elbereth' => 0,
                         'mr' => 40,
                         'glyph' => '@'
                       },
          'shocking sphere' => {
                                 'atk' => 'X4d6E',
                                 'spd' => 13,
                                 'ac' => 4,
                                 'corpse' => {
                                               'cannibal' => 0,
                                               'weight' => 10,
                                               'nutrition' => 0
                                             },
                                 'res' => 'E',
                                 'lev' => 6,
                                 'elbereth' => 1,
                                 'mr' => 0,
                                 'glyph' => 'e'
                               },
          'Lord Sato' => {
                           'atk' => 'W1d8 W1d6',
                           'spd' => 12,
                           'ac' => 0,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 20,
                           'elbereth' => 0,
                           'mr' => 30,
                           'glyph' => '@'
                         },
          'giant mimic' => {
                             'atk' => '3d6m 3d6m',
                             'spd' => 3,
                             'ac' => 7,
                             'corpse' => {
                                           'mimic' => '50',
                                           'cannibal' => 0,
                                           'weight' => 800,
                                           'nutrition' => 500
                                         },
                             'res' => 'a',
                             'lev' => 9,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'm'
                           },
          'dwarf lord' => {
                            'atk' => 'W2d4 W2d4',
                            'spd' => 6,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 'Dwa',
                                          'weight' => 900,
                                          'nutrition' => 300
                                        },
                            'res' => ' ',
                            'lev' => 4,
                            'elbereth' => 1,
                            'mr' => 10,
                            'glyph' => 'h'
                          },
          'gray ooze' => {
                           'atk' => '2d8R',
                           'spd' => 1,
                           'ac' => 8,
                           'corpse' => {
                                         'poison' => '7',
                                         'cold' => '7',
                                         'nutrition' => 250,
                                         'cannibal' => 0,
                                         'fire' => '7',
                                         'weight' => 500,
                                         'acidic' => 1
                                       },
                           'res' => 'FCPa*',
                           'lev' => 3,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'P'
                         },
          'dingo' => {
                       'atk' => '1d6',
                       'spd' => 16,
                       'ac' => 5,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 400,
                                     'nutrition' => 200
                                   },
                       'res' => ' ',
                       'lev' => 4,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'd'
                     },
          'vrock' => {
                       'atk' => '1d4 1d4 1d8 1d8 1d6',
                       'spd' => 12,
                       'ac' => 0,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1450,
                                     'nutrition' => 0
                                   },
                       'res' => 'fp',
                       'lev' => 8,
                       'elbereth' => 1,
                       'mr' => 50,
                       'glyph' => '&'
                     },
          'ettin zombie' => {
                              'atk' => '1d10 1d10',
                              'spd' => 8,
                              'ac' => 6,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1700,
                                            'nutrition' => 250
                                          },
                              'res' => 'csp',
                              'lev' => 6,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'Z'
                            },
          'baby silver dragon' => {
                                    'atk' => '2d6',
                                    'spd' => 9,
                                    'ac' => 2,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 1500,
                                                  'nutrition' => 500
                                                },
                                    'res' => ' ',
                                    'lev' => 12,
                                    'elbereth' => 1,
                                    'mr' => 10,
                                    'glyph' => 'D'
                                  },
          'guardian naga hatchling' => {
                                         'atk' => '1d4',
                                         'spd' => 10,
                                         'ac' => 6,
                                         'corpse' => {
                                                       'poison' => '20',
                                                       'cannibal' => 0
                                                     },
                                         'res' => 'P',
                                         'lev' => 3,
                                         'elbereth' => 0,
                                         'mr' => 0,
                                         'glyph' => 'N'
                                       },
          'Geryon' => {
                        'atk' => '3d6 3d6 2d4P',
                        'spd' => 3,
                        'ac' => -3,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1500,
                                      'nutrition' => 0
                                    },
                        'res' => 'fp',
                        'lev' => 72,
                        'elbereth' => 1,
                        'mr' => 75,
                        'glyph' => '&'
                      },
          'wraith' => {
                        'atk' => '1d6V',
                        'spd' => 12,
                        'ac' => 4,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 0,
                                      'nutrition' => 0
                                    },
                        'res' => 'csp*',
                        'lev' => 6,
                        'elbereth' => 1,
                        'mr' => 15,
                        'glyph' => 'W'
                      },
          'centipede' => {
                           'atk' => '1d3P',
                           'spd' => 4,
                           'ac' => 3,
                           'corpse' => {
                                         'poison' => '13',
                                         'cannibal' => 0,
                                         'weight' => 50,
                                         'nutrition' => 50
                                       },
                           'res' => 'P',
                           'lev' => 2,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 's'
                         },
          'scorpion' => {
                          'atk' => '1d2 1d2 1d4P',
                          'spd' => 15,
                          'ac' => 3,
                          'corpse' => {
                                        'poison' => '50',
                                        'cannibal' => 0,
                                        'weight' => 50,
                                        'poisonous' => 1,
                                        'nutrition' => 100
                                      },
                          'res' => 'P',
                          'lev' => 5,
                          'elbereth' => 1,
                          'mr' => 0,
                          'glyph' => 's'
                        },
          'goblin' => {
                        'atk' => 'W1d4',
                        'spd' => 6,
                        'ac' => 10,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 400,
                                      'nutrition' => 100
                                    },
                        'res' => ' ',
                        'lev' => 0,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'o'
                      },
          'acolyte' => {
                         'atk' => 'W1d6 M0d0+',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 0,
                         'mr' => 20,
                         'glyph' => '@'
                       },
          'elf zombie' => {
                            'atk' => '1d7',
                            'spd' => 6,
                            'ac' => 9,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 800,
                                          'nutrition' => 175
                                        },
                            'res' => 'csp',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'Z'
                          },
          'salamander' => {
                            'atk' => 'W2d8 1d6F H2d6 H3d6F',
                            'spd' => 12,
                            'ac' => -1,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'fire' => '53',
                                          'weight' => 1500,
                                          'poisonous' => 1,
                                          'nutrition' => 400
                                        },
                            'res' => 'Fs',
                            'lev' => 8,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => ':'
                          },
          'shade' => {
                       'atk' => '2d6. 1d6&lt;',
                       'spd' => 10,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1450,
                                     'nutrition' => 0
                                   },
                       'res' => 'csdp*',
                       'lev' => 12,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'X'
                     },
          'pony' => {
                      'atk' => '1d6 1d2',
                      'spd' => 16,
                      'ac' => 6,
                      'corpse' => {
                                    'cannibal' => 0,
                                    'weight' => 1300,
                                    'nutrition' => 250
                                  },
                      'res' => ' ',
                      'lev' => 3,
                      'elbereth' => 1,
                      'mr' => 0,
                      'glyph' => 'u'
                    },
          'student' => {
                         'atk' => 'W1d6',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 0,
                         'mr' => 10,
                         'glyph' => '@'
                       },
          'giant zombie' => {
                              'atk' => '2d8 2d8',
                              'spd' => 8,
                              'ac' => 6,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 2050,
                                            'nutrition' => 375
                                          },
                              'res' => 'csp',
                              'lev' => 8,
                              'elbereth' => 1,
                              'mr' => 0,
                              'glyph' => 'Z'
                            },
          'cavewoman' => {
                           'atk' => 'W2d4',
                           'spd' => 12,
                           'ac' => 10,
                           'corpse' => {
                                         'cannibal' => 'Hum',
                                         'weight' => 1450,
                                         'nutrition' => 400
                                       },
                           'res' => ' ',
                           'lev' => 10,
                           'elbereth' => 0,
                           'mr' => 0,
                           'glyph' => '@'
                         },
          'spotted jelly' => {
                               'atk' => '(0d6A)',
                               'spd' => 0,
                               'ac' => 8,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 50,
                                             'nutrition' => 20,
                                             'acidic' => 1
                                           },
                               'res' => 'a*',
                               'lev' => 5,
                               'elbereth' => 1,
                               'mr' => 10,
                               'glyph' => 'j'
                             },
          'neanderthal' => {
                             'atk' => 'W2d4',
                             'spd' => 12,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 'Hum',
                                           'weight' => 1450,
                                           'nutrition' => 400
                                         },
                             'res' => ' ',
                             'lev' => 5,
                             'elbereth' => 0,
                             'mr' => 10,
                             'glyph' => '@'
                           },
          'horned devil' => {
                              'atk' => 'W1d4 1d4 2d3 1d3',
                              'spd' => 9,
                              'ac' => -5,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 1450,
                                            'nutrition' => 0
                                          },
                              'res' => 'fp',
                              'lev' => 6,
                              'elbereth' => 1,
                              'mr' => 50,
                              'glyph' => '&'
                            },
          'balrog' => {
                        'atk' => 'W8d4 W4d6',
                        'spd' => 5,
                        'ac' => -2,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 1450,
                                      'nutrition' => 0
                                    },
                        'res' => 'fp',
                        'lev' => 16,
                        'elbereth' => 1,
                        'mr' => 75,
                        'glyph' => '&'
                      },
          'dwarf mummy' => {
                             'atk' => '1d6',
                             'spd' => 10,
                             'ac' => 5,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 900,
                                           'nutrition' => 150
                                         },
                             'res' => 'csp',
                             'lev' => 5,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'M'
                           },
          'large cat' => {
                           'atk' => '2d4',
                           'spd' => 15,
                           'ac' => 4,
                           'corpse' => {
                                         'aggravate' => 1,
                                         'cannibal' => 0,
                                         'weight' => 250,
                                         'nutrition' => 250
                                       },
                           'res' => ' ',
                           'lev' => 6,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'f'
                         },
          'dwarf' => {
                       'atk' => 'W1d8',
                       'spd' => 6,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 'Dwa',
                                     'weight' => 900,
                                     'nutrition' => 300
                                   },
                       'res' => ' ',
                       'lev' => 2,
                       'elbereth' => 1,
                       'mr' => 10,
                       'glyph' => 'h'
                     },
          'giant' => {
                       'atk' => 'W2d10',
                       'spd' => 6,
                       'ac' => 0,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 2250,
                                     'nutrition' => 750,
                                     'strength' => 1
                                   },
                       'res' => ' ',
                       'lev' => 6,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'H'
                     },
          'straw golem' => {
                             'atk' => '1d2 1d2',
                             'spd' => 12,
                             'ac' => 10,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 400,
                                           'nutrition' => 0
                                         },
                             'res' => 'sp',
                             'lev' => 3,
                             'elbereth' => 1,
                             'mr' => 0,
                             'glyph' => '\''
                           },
          'sergeant' => {
                          'atk' => 'W2d6',
                          'spd' => 10,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => ' ',
                          'lev' => 8,
                          'elbereth' => 0,
                          'mr' => 5,
                          'glyph' => '@'
                        },
          'glass golem' => {
                             'atk' => '2d8 2d8',
                             'spd' => 6,
                             'ac' => 1,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 1800,
                                           'nutrition' => 0
                                         },
                             'res' => 'spa',
                             'lev' => 16,
                             'elbereth' => 1,
                             'mr' => 50,
                             'glyph' => '\''
                           },
          'Lord Carnarvon' => {
                                'atk' => 'W1d6',
                                'spd' => 12,
                                'ac' => 0,
                                'corpse' => {
                                              'cannibal' => 'Hum',
                                              'weight' => 1450,
                                              'nutrition' => 400
                                            },
                                'res' => ' ',
                                'lev' => 20,
                                'elbereth' => 0,
                                'mr' => 30,
                                'glyph' => '@'
                              },
          'page' => {
                      'atk' => 'W1d6 W1d6',
                      'spd' => 12,
                      'ac' => 10,
                      'corpse' => {
                                    'cannibal' => 'Hum',
                                    'weight' => 1450,
                                    'nutrition' => 400
                                  },
                      'res' => ' ',
                      'lev' => 5,
                      'elbereth' => 0,
                      'mr' => 10,
                      'glyph' => '@'
                    },
          'snake' => {
                       'atk' => '1d6P',
                       'spd' => 15,
                       'ac' => 3,
                       'corpse' => {
                                     'poison' => '27',
                                     'cannibal' => 0,
                                     'weight' => 100,
                                     'poisonous' => 1,
                                     'nutrition' => 80
                                   },
                       'res' => 'P',
                       'lev' => 4,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'S'
                     },
          'ghoul' => {
                       'atk' => '1d2. 1d3',
                       'spd' => 6,
                       'ac' => 10,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 400,
                                     'nutrition' => 0
                                   },
                       'res' => 'csp',
                       'lev' => 3,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'Z'
                     },
          'shark' => {
                       'atk' => '5d6',
                       'spd' => 12,
                       'ac' => 2,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 500,
                                     'nutrition' => 350
                                   },
                       'res' => ' ',
                       'lev' => 7,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => ';'
                     },
          'nalfeshnee' => {
                            'atk' => '1d4 1d4 2d4 M0d0+',
                            'spd' => 9,
                            'ac' => -1,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1450,
                                          'nutrition' => 0
                                        },
                            'res' => 'fp',
                            'lev' => 11,
                            'elbereth' => 1,
                            'mr' => 65,
                            'glyph' => '&'
                          },
          'imp' => {
                     'atk' => '1d4',
                     'spd' => 12,
                     'ac' => 2,
                     'corpse' => {
                                   'cannibal' => 0,
                                   'weight' => 20,
                                   'nutrition' => 10
                                 },
                     'res' => ' ',
                     'lev' => 3,
                     'elbereth' => 1,
                     'mr' => 20,
                     'glyph' => 'i'
                   },
          'rothe' => {
                       'atk' => '1d3 1d3 1d8',
                       'spd' => 9,
                       'ac' => 7,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 400,
                                     'nutrition' => 100
                                   },
                       'res' => ' ',
                       'lev' => 2,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'q'
                     },
          'mumak' => {
                       'atk' => '4d12 2d6',
                       'spd' => 9,
                       'ac' => 0,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 2500,
                                     'nutrition' => 500
                                   },
                       'res' => ' ',
                       'lev' => 5,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'q'
                     },
          'Norn' => {
                      'atk' => 'W1d8 W1d6',
                      'spd' => 12,
                      'ac' => 0,
                      'corpse' => {
                                    'cannibal' => 'Hum',
                                    'weight' => 1450,
                                    'nutrition' => 400
                                  },
                      'res' => 'c',
                      'lev' => 20,
                      'elbereth' => 0,
                      'mr' => 80,
                      'glyph' => '@'
                    },
          'orange dragon' => {
                               'atk' => 'B4d25S 3d8 1d4 1d4',
                               'spd' => 9,
                               'ac' => -1,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 4500,
                                             'nutrition' => 1500,
                                             'sleep' => '100'
                                           },
                               'res' => 'S',
                               'lev' => 15,
                               'elbereth' => 1,
                               'mr' => 20,
                               'glyph' => 'D'
                             },
          'Minion of Huhetotl' => {
                                    'atk' => 'W8d4 W4d6 M0d0+ 2d6-',
                                    'spd' => 12,
                                    'ac' => -2,
                                    'corpse' => {
                                                  'cannibal' => 0,
                                                  'weight' => 1450,
                                                  'nutrition' => 0
                                                },
                                    'res' => 'fp*',
                                    'lev' => 16,
                                    'elbereth' => 1,
                                    'mr' => 75,
                                    'glyph' => '&'
                                  },
          'fire vortex' => {
                             'atk' => 'E1d10F (0d4F)',
                             'spd' => 22,
                             'ac' => 2,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'weight' => 0,
                                           'nutrition' => 0
                                         },
                             'res' => 'fsp*',
                             'lev' => 8,
                             'elbereth' => 1,
                             'mr' => 30,
                             'glyph' => 'v'
                           },
          'little dog' => {
                            'atk' => '1d6',
                            'spd' => 18,
                            'ac' => 6,
                            'corpse' => {
                                          'aggravate' => 1,
                                          'cannibal' => 0,
                                          'weight' => 150,
                                          'nutrition' => 150
                                        },
                            'res' => ' ',
                            'lev' => 2,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'd'
                          },
          'guardian naga hatchl' => {
                                      'corpse' => {
                                                    'weight' => 500,
                                                    'nutrition' => 100
                                                  }
                                    },
          'rock mole' => {
                           'atk' => '1d6',
                           'spd' => 3,
                           'ac' => 0,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 30,
                                         'nutrition' => 30
                                       },
                           'res' => ' ',
                           'lev' => 3,
                           'elbereth' => 1,
                           'mr' => 20,
                           'glyph' => 'r'
                         },
          'Shaman Karnov' => {
                               'atk' => 'W2d4',
                               'spd' => 12,
                               'ac' => 0,
                               'corpse' => {
                                             'cannibal' => 'Hum',
                                             'weight' => 1450,
                                             'nutrition' => 400
                                           },
                               'res' => ' ',
                               'lev' => 20,
                               'elbereth' => 0,
                               'mr' => 30,
                               'glyph' => '@'
                             },
          'giant rat' => {
                           'atk' => '1d3',
                           'spd' => 10,
                           'ac' => 7,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 30,
                                         'nutrition' => 30
                                       },
                           'res' => ' ',
                           'lev' => 1,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'r'
                         },
          'green mold' => {
                            'atk' => '(0d4A)',
                            'spd' => 0,
                            'ac' => 9,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 50,
                                          'nutrition' => 30,
                                          'acidic' => 1
                                        },
                            'res' => 'a*',
                            'lev' => 1,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'F'
                          },
          'leather golem' => {
                               'atk' => '1d6 1d6',
                               'spd' => 6,
                               'ac' => 6,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 800,
                                             'nutrition' => 0
                                           },
                               'res' => 'sp',
                               'lev' => 6,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => '\''
                             },
          'queen bee' => {
                           'atk' => '1d8P',
                           'spd' => 24,
                           'ac' => -4,
                           'corpse' => {
                                         'poison' => '60',
                                         'cannibal' => 0,
                                         'weight' => 1,
                                         'poisonous' => 1,
                                         'nutrition' => 5
                                       },
                           'res' => 'P',
                           'lev' => 9,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'a'
                         },
          'ogre' => {
                      'atk' => 'W2d5',
                      'spd' => 10,
                      'ac' => 5,
                      'corpse' => {
                                    'cannibal' => 0,
                                    'weight' => 1600,
                                    'nutrition' => 500
                                  },
                      'res' => ' ',
                      'lev' => 5,
                      'elbereth' => 1,
                      'mr' => 0,
                      'glyph' => 'O'
                    },
          'clay golem' => {
                            'atk' => '3d10',
                            'spd' => 7,
                            'ac' => 7,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1550,
                                          'nutrition' => 0
                                        },
                            'res' => 'sp',
                            'lev' => 11,
                            'elbereth' => 1,
                            'mr' => 40,
                            'glyph' => '\''
                          },
          'gnome lord' => {
                            'atk' => 'W1d8',
                            'spd' => 8,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 'Gno',
                                          'weight' => 700,
                                          'nutrition' => 120
                                        },
                            'res' => ' ',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 4,
                            'glyph' => 'G'
                          },
          'violet fungus' => {
                               'atk' => '1d4 0d0m',
                               'spd' => 1,
                               'ac' => 7,
                               'corpse' => {
                                             'cannibal' => 0,
                                             'weight' => 100,
                                             'nutrition' => 100
                                           },
                               'res' => 'P',
                               'lev' => 3,
                               'elbereth' => 1,
                               'mr' => 0,
                               'glyph' => 'F'
                             },
          'Demogorgon' => {
                            'atk' => 'M8d6+ 1d4V 1d6# 1d6#',
                            'spd' => 15,
                            'ac' => -8,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1500,
                                          'nutrition' => 0
                                        },
                            'res' => 'fp',
                            'lev' => 106,
                            'elbereth' => 1,
                            'mr' => 95,
                            'glyph' => '&'
                          },
          'kobold mummy' => {
                              'atk' => '1d4',
                              'spd' => 8,
                              'ac' => 6,
                              'corpse' => {
                                            'cannibal' => 0,
                                            'weight' => 400,
                                            'nutrition' => 50
                                          },
                              'res' => 'csp',
                              'lev' => 3,
                              'elbereth' => 1,
                              'mr' => 20,
                              'glyph' => 'M'
                            },
          'umber hulk' => {
                            'atk' => '3d4 3d4 2d5 G0d0c',
                            'spd' => 6,
                            'ac' => 2,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1200,
                                          'nutrition' => 500
                                        },
                            'res' => ' ',
                            'lev' => 9,
                            'elbereth' => 1,
                            'mr' => 25,
                            'glyph' => 'U'
                          },
          'lemure' => {
                        'atk' => '1d3',
                        'spd' => 3,
                        'ac' => 7,
                        'corpse' => {
                                      'cannibal' => 0,
                                      'weight' => 150,
                                      'nutrition' => 0
                                    },
                        'res' => 'Sp',
                        'lev' => 3,
                        'elbereth' => 1,
                        'mr' => 0,
                        'glyph' => 'i'
                      },
          'blue dragon' => {
                             'atk' => 'B4d6E 3d8 1d4 1d4',
                             'spd' => 9,
                             'ac' => -1,
                             'corpse' => {
                                           'cannibal' => 0,
                                           'shock' => '100',
                                           'weight' => 4500,
                                           'nutrition' => 1500
                                         },
                             'res' => 'E',
                             'lev' => 15,
                             'elbereth' => 1,
                             'mr' => 20,
                             'glyph' => 'D'
                           },
          'watch captain' => {
                               'atk' => 'W3d4 W3d4',
                               'spd' => 10,
                               'ac' => 10,
                               'corpse' => {
                                             'cannibal' => 'Hum',
                                             'weight' => 1450,
                                             'nutrition' => 400
                                           },
                               'res' => ' ',
                               'lev' => 10,
                               'elbereth' => 0,
                               'mr' => 15,
                               'glyph' => '@'
                             },
          'Death' => {
                       'atk' => '8d8z 8d8z',
                       'spd' => 12,
                       'ac' => -5,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 1450,
                                     'die' => 1,
                                     'nutrition' => 1
                                   },
                       'res' => 'fcsep*',
                       'lev' => 30,
                       'elbereth' => 0,
                       'mr' => 100,
                       'glyph' => '&'
                     },
          'xan' => {
                     'atk' => '1d4x',
                     'spd' => 18,
                     'ac' => -4,
                     'corpse' => {
                                   'poison' => '47',
                                   'cannibal' => 0,
                                   'weight' => 300,
                                   'poisonous' => 1,
                                   'nutrition' => 300
                                 },
                     'res' => 'P',
                     'lev' => 7,
                     'elbereth' => 1,
                     'mr' => 0,
                     'glyph' => 'x'
                   },
          'homunculi' => {
                           'corpse' => {
                                         'poison' => '7',
                                         'poisonous' => 1,
                                         'sleep' => '7'
                                       }
                         },
          'wizard' => {
                        'atk' => 'W1d6',
                        'spd' => 12,
                        'ac' => 10,
                        'corpse' => {
                                      'cannibal' => 'Hum',
                                      'weight' => 1450,
                                      'nutrition' => 400
                                    },
                        'res' => ' ',
                        'lev' => 10,
                        'elbereth' => 0,
                        'mr' => 3,
                        'glyph' => '@'
                      },
          'piranha' => {
                         'atk' => '2d6',
                         'spd' => 12,
                         'ac' => 4,
                         'corpse' => {
                                       'cannibal' => 0,
                                       'weight' => 60,
                                       'nutrition' => 30
                                     },
                         'res' => ' ',
                         'lev' => 5,
                         'elbereth' => 1,
                         'mr' => 0,
                         'glyph' => ';'
                       },
          'sewer rat' => {
                           'atk' => '1d3',
                           'spd' => 12,
                           'ac' => 7,
                           'corpse' => {
                                         'cannibal' => 0,
                                         'weight' => 20,
                                         'nutrition' => 12
                                       },
                           'res' => ' ',
                           'lev' => 0,
                           'elbereth' => 1,
                           'mr' => 0,
                           'glyph' => 'r'
                         },
          'samurai' => {
                         'atk' => 'W1d8 W1d8',
                         'spd' => 12,
                         'ac' => 10,
                         'corpse' => {
                                       'cannibal' => 'Hum',
                                       'weight' => 1450,
                                       'nutrition' => 400
                                     },
                         'res' => ' ',
                         'lev' => 10,
                         'elbereth' => 0,
                         'mr' => 1,
                         'glyph' => '@'
                       },
          'Mordor orc' => {
                            'atk' => 'W1d6',
                            'spd' => 5,
                            'ac' => 10,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1200,
                                          'nutrition' => 200
                                        },
                            'res' => ' ',
                            'lev' => 3,
                            'elbereth' => 1,
                            'mr' => 0,
                            'glyph' => 'o'
                          },
          'troll' => {
                       'atk' => 'W4d2 4d2 2d6',
                       'spd' => 12,
                       'ac' => 4,
                       'corpse' => {
                                     'cannibal' => 0,
                                     'weight' => 800,
                                     'nutrition' => 350
                                   },
                       'res' => ' ',
                       'lev' => 7,
                       'elbereth' => 1,
                       'mr' => 0,
                       'glyph' => 'T'
                     },
          'Master of Thieves' => {
                                   'atk' => 'W2d6 W2d6 2d4-',
                                   'spd' => 12,
                                   'ac' => 0,
                                   'corpse' => {
                                                 'cannibal' => 'Hum',
                                                 'weight' => 1450,
                                                 'nutrition' => 400
                                               },
                                   'res' => '*',
                                   'lev' => 20,
                                   'elbereth' => 0,
                                   'mr' => 30,
                                   'glyph' => '@'
                                 },
          'doppelganger' => {
                              'atk' => 'W1d12',
                              'spd' => 12,
                              'ac' => 5,
                              'corpse' => {
                                            'polymorph' => 1,
                                            'cannibal' => 'Hum',
                                            'weight' => 1450,
                                            'nutrition' => 400
                                          },
                              'res' => 's',
                              'lev' => 9,
                              'elbereth' => 0,
                              'mr' => 20,
                              'glyph' => '@'
                            },
          'valkyrie' => {
                          'atk' => 'W1d8 W1d8',
                          'spd' => 12,
                          'ac' => 10,
                          'corpse' => {
                                        'cannibal' => 'Hum',
                                        'weight' => 1450,
                                        'nutrition' => 400
                                      },
                          'res' => 'c',
                          'lev' => 10,
                          'elbereth' => 0,
                          'mr' => 1,
                          'glyph' => '@'
                        },
          'bone devil' => {
                            'atk' => 'W3d4 2d4P',
                            'spd' => 15,
                            'ac' => -1,
                            'corpse' => {
                                          'cannibal' => 0,
                                          'weight' => 1450,
                                          'nutrition' => 0
                                        },
                            'res' => 'fp',
                            'lev' => 9,
                            'elbereth' => 1,
                            'mr' => 40,
                            'glyph' => '&'
                          }
      }
  },
);

sub monster {
  my $self = shift;
  my $arg  = shift;
  return exists $self->monst->{$arg} ? $self->monst->{arg} : undef;
}

1;

