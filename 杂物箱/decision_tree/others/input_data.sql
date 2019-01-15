-- 数据获取sql
select jglb 机构类别,
       hznl 患者类别,
       ksmc 科室名称,
       hzxb 性别,
       jgdj 机构代码,
       zje  总金额
  from wuxi.ck10_ghdj
 where jgmc = '二院'
   and ryzddm = 'R50.901'