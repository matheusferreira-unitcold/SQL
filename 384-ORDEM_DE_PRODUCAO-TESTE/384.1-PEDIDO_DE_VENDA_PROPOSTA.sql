select distinct tgfcab.nunota,
                tgfcab.numnota,
                tgfcab.dtneg,
                tgfcab.codparc,
                tgfpar.nomeparc,
                tgfcab.ad_nproposta,
                tgfcab.codtipoper,
                tgfcab.statusnota
  from tgfcab
 inner join tgftop
on tgfcab.codtipoper = tgftop.codtipoper
 inner join tgfpar
on tgfcab.codparc = tgfpar.codparc
 where tgftop.tipmov = 'P'