#
type Facter::Conf = Struct[{'facts'  => Optional[Struct[{
                                          'blocklist' => Optional[Array[String]],
                                          'ttls'      => Optional[Array[Hash]]
                                          }]],
                            'global' => Optional[Struct[{
                                          'external-dir'      => Optional[Array[Stdlib::Absolutepath]],
                                          'custom-dir'        => Optional[Array[Stdlib::Absolutepath]],
                                          'no-external-facts' => Optional[Boolean],
                                          'no-custom-facts'   => Optional[Boolean],
                                          'no-ruby'           => Optional[Boolean]
                                          }]],
                            'cli'    => Optional[Struct[{
                                          'debug'     => Optional[Boolean],
                                          'trace'     => Optional[Boolean],
                                          'verbose'   => Optional[Boolean],
                                          'log-level' => Optional[Boolean]
                                          }]]
                          }]