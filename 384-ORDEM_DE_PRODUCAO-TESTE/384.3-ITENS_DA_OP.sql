select op.idiproc,
       mp.codprodmp,
       p1.descrprod,
       sum(ipa.qtdproduzir * mp.qtdmistura) as qtdneclote,
       mp.codvol
  from tpriproc op
 inner join tpripa ipa
on op.idiproc = ipa.idiproc
 inner join tprlmp mp
on mp.codprodpa = ipa.codprodpa
   and mp.idefx in (
   select idefx
     from tprefx
    where idproc = op.idproc
)
 inner join tgfpro p1
on mp.codprodmp = p1.codprod
 inner join tprplp pla
on op.codplp = pla.codplp
 where op.statusproc in ( 'A',
                          'R',
                          'P',
                          'P2' )
   and p1.usoprod not in ( '2',
                           'V' )
 group by op.idiproc,
          mp.codprodmp,
          p1.descrprod,
          mp.codvol