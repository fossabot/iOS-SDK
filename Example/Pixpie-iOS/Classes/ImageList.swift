//
//  ImageList.swift
//  Pixpie-iOS
//
//  Created by Dmitry Osipa on 2/12/16.
//  Copyright © 2016 Pixpie. All rights reserved.
//

import Foundation

let kImageLinkArray: [String] = ["https://farm2.staticflickr.com/1442/24937114956_2b32c75a0e_z.jpg",
                                 "https://farm2.staticflickr.com/1444/24326038983_038d2ce490_z.jpg",
                                 "https://farm2.staticflickr.com/1445/24328877053_ec1ed4072d_z.jpg",
                                 "https://farm2.staticflickr.com/1445/24842597162_e53409e76e_z.jpg",
                                 "https://farm2.staticflickr.com/1446/24857761071_0ea6407c58_z.jpg",
                                 "https://farm2.staticflickr.com/1450/24665545330_e595ecde45_z.jpg",
                                 "https://farm2.staticflickr.com/1452/24832007552_e610bb3841_z.jpg",
                                 "https://farm2.staticflickr.com/1453/24333350263_8c3341be07_z.jpg",
                                 "https://farm2.staticflickr.com/1453/24665479840_5d87264d24_z.jpg",
                                 "https://farm2.staticflickr.com/1462/24949290515_2434b29189_z.jpg",
                                 "https://farm2.staticflickr.com/1464/24843409072_3051cf7fbb_z.jpg",
                                 "https://farm2.staticflickr.com/1468/24329781514_1435458ebf_z.jpg",
                                 "https://farm2.staticflickr.com/1470/24329744173_0f77fc0f90_z.jpg",
                                 "https://farm2.staticflickr.com/1474/24956111745_c41bf45d9c_z.jpg",
                                 "https://farm2.staticflickr.com/1477/24928509136_6a3bbd46a6_z.jpg",
                                 "https://farm2.staticflickr.com/1478/24961339355_d09f4c2749_z.jpg",
                                 "https://farm2.staticflickr.com/1480/24928600606_1f66ab2660_z.jpg",
                                 "https://farm2.staticflickr.com/1483/24864033411_a0a3d60bc9_z.jpg",
                                 "https://farm2.staticflickr.com/1494/24865327461_d3d512a739_z.jpg",
                                 "https://farm2.staticflickr.com/1497/24332635243_fb0e0f8f8e_z.jpg",
                                 "https://farm2.staticflickr.com/1500/24327737723_5f9768108f_z.jpg",
                                 "https://farm2.staticflickr.com/1507/24331408963_e7975e4ea8_z.jpg",
                                 "https://farm2.staticflickr.com/1509/24930971586_aaf4999fc9_z.jpg",
                                 "https://farm2.staticflickr.com/1515/24580729449_f6bec25b1e_z.jpg",
                                 "https://farm2.staticflickr.com/1518/24589782449_0cde064809_z.jpg",
                                 "https://farm2.staticflickr.com/1520/24330829813_944c817720_z.jpg",
                                 "https://farm2.staticflickr.com/1526/24842979272_c97a11ec58_z.jpg",
                                 "https://farm2.staticflickr.com/1531/24653852390_f8506f65cb_z.jpg",
                                 "https://farm2.staticflickr.com/1539/24335322713_d21bb23cdf_z.jpg",
                                 "https://farm2.staticflickr.com/1541/24859145711_4e5b454aee_z.jpg",
                                 "https://farm2.staticflickr.com/1544/24928842856_bc51212ea4_z.jpg",
                                 "https://farm2.staticflickr.com/1545/24596957859_5e375a7c45_z.jpg",
                                 "https://farm2.staticflickr.com/1547/24828802912_5776dafec8_z.jpg",
                                 "https://farm2.staticflickr.com/1548/24832914482_394255af2f_z.jpg",
                                 "https://farm2.staticflickr.com/1557/24859857941_fe2d564919_z.jpg",
                                 "https://farm2.staticflickr.com/1560/24660231070_e9e97a5747_z.jpg",
                                 "https://farm2.staticflickr.com/1563/24963662035_1b8a184b7d_z.jpg",
                                 "https://farm2.staticflickr.com/1565/24951063675_40fd9425d7_z.jpg",
                                 "https://farm2.staticflickr.com/1572/24960809185_87fb86b533_z.jpg",
                                 "https://farm2.staticflickr.com/1578/24319988733_f5f6c10e4e_z.jpg",
                                 "https://farm2.staticflickr.com/1581/24328057103_07ba61fdf5_z.jpg",
                                 "https://farm2.staticflickr.com/1583/24869440371_c7a0f14ccf_z.jpg",
                                 "https://farm2.staticflickr.com/1583/24962372355_e442a69809_z.jpg",
                                 "https://farm2.staticflickr.com/1591/24582025659_e0dc3e97ba_z.jpg",
                                 "https://farm2.staticflickr.com/1593/24333333484_0430a7e476_z.jpg",
                                 "https://farm2.staticflickr.com/1593/24593098389_a576788f6f_z.jpg",
                                 "https://farm2.staticflickr.com/1599/24589935899_084a927ebf_z.jpg",
                                 "https://farm2.staticflickr.com/1601/24656794410_a93a5f681a_z.jpg",
                                 "https://farm2.staticflickr.com/1605/24592218349_ef91fe3e34_z.jpg",
                                 "https://farm2.staticflickr.com/1605/24961032675_aff8d37535_z.jpg",
                                 "https://farm2.staticflickr.com/1607/24328193964_942f3d98ec_z.jpg",
                                 "https://farm2.staticflickr.com/1607/24663368100_7aa83e76d5_z.jpg",
                                 "https://farm2.staticflickr.com/1613/24580914349_3b5f7828ca_z.jpg",
                                 "https://farm2.staticflickr.com/1614/24868723181_dae7d9fdbb_z.jpg",
                                 "https://farm2.staticflickr.com/1616/24935691516_993e3a9281_z.jpg",
                                 "https://farm2.staticflickr.com/1620/24871028331_236224ab09_z.jpg",
                                 "https://farm2.staticflickr.com/1624/24329246023_0b0242da3d_z.jpg",
                                 "https://farm2.staticflickr.com/1634/24924699396_c2ea70f6fd_z.jpg",
                                 "https://farm2.staticflickr.com/1635/24661971770_4535aa1b74_z.jpg",
                                 "https://farm2.staticflickr.com/1640/24958332615_0062b3cbc2_z.jpg",
                                 "https://farm2.staticflickr.com/1651/24920656026_b87bc41456_z.jpg",
                                 "https://farm2.staticflickr.com/1658/24963778925_4792aff808_z.jpg",
                                 "https://farm2.staticflickr.com/1662/24326085293_9b85746101_z.jpg",
                                 "https://farm2.staticflickr.com/1662/24947025935_20d50b3621_z.jpg",
                                 "https://farm2.staticflickr.com/1666/24591221539_7d4a8babbc_z.jpg",
                                 "https://farm2.staticflickr.com/1667/24321166513_e769966aa1_z.jpg",
                                 "https://farm2.staticflickr.com/1667/24331573164_b5ab017118_z.jpg",
                                 "https://farm2.staticflickr.com/1672/24324162993_20734edd3a_z.jpg",
                                 "https://farm2.staticflickr.com/1672/24932993676_579a71513d_z.jpg",
                                 "https://farm2.staticflickr.com/1675/24831922102_a8002b1bde_z.jpg",
                                 "https://farm2.staticflickr.com/1679/24856916961_c2400b0cc7_z.jpg",
                                 "https://farm2.staticflickr.com/1682/24664066300_0493c93345_z.jpg",
                                 "https://farm2.staticflickr.com/1683/24652957570_2cbef502e2_z.jpg",
                                 "https://farm2.staticflickr.com/1684/24667722610_87c4e08b7a_z.jpg",
                                 "https://farm2.staticflickr.com/1684/24956133005_7491f76f20_z.jpg",
                                 "https://farm2.staticflickr.com/1686/24954368965_afdd134118_z.jpg",
                                 "https://farm2.staticflickr.com/1694/24589088039_b3a5c2b4f4_z.jpg",
                                 "https://farm2.staticflickr.com/1700/24335521013_53dccfca20_z.jpg",
                                 "https://farm2.staticflickr.com/1700/24338362463_598bf77051_z.jpg",
                                 "https://farm2.staticflickr.com/1712/24964866055_5929cbff00_z.jpg",
                                 "https://farm2.staticflickr.com/1714/24317398044_0022ae4faf_z.jpg",
                                 "https://farm2.staticflickr.com/1716/24841935152_e67fc6915a_z.jpg",
                                 "https://farm2.staticflickr.com/1441/24863572111_9449e804ed_z.jpg",
                                 "https://farm2.staticflickr.com/1687/26249720600_3ac5d77308_z.jpg",
                                 "https://farm2.staticflickr.com/1683/25919347243_ebe327cd7b_z.jpg",
                                 "https://farm2.staticflickr.com/1501/25912343484_a95666177e_z.jpg",
                                 "https://farm2.staticflickr.com/1650/26513810135_66a33e5509_z.jpg",
                                 "https://farm2.staticflickr.com/1502/26528049875_e8e78b65b3_z.jpg",
                                 "https://farm2.staticflickr.com/1613/25925447583_53de0f8781_z.jpg",
                                 "https://farm2.staticflickr.com/1525/26420862192_8749c16cfe_z.jpg",
                                 "https://farm2.staticflickr.com/1503/26518025855_45c1ce369a_z.jpg",
                                 "https://farm2.staticflickr.com/1460/25915879963_74d9729389_z.jpg",
                                 "https://farm2.staticflickr.com/1574/26525872085_486e23945b_z.jpg",
                                 "https://farm2.staticflickr.com/1470/25922314833_4a7ba64720_z.jpg",
                                 "https://farm2.staticflickr.com/1577/25912856944_ddaa61fc36_z.jpg",
                                 "https://farm2.staticflickr.com/1583/26517785445_877e85d159_z.jpg",
                                 "https://farm2.staticflickr.com/1444/26246836950_2a19e00c12_z.jpg",
                                 "https://farm2.staticflickr.com/1688/26425009852_bd159c0be8_z.jpg",
                                 "https://farm2.staticflickr.com/1628/26498748446_5dee0af8e8_z.jpg",
                                 "https://farm2.staticflickr.com/1476/26428112972_31f88a0ce9_z.jpg",
                                 "https://farm2.staticflickr.com/1629/26250329380_e1e1abd5cf_z.jpg",
                                 "https://farm2.staticflickr.com/1579/26450043351_03f9ab4538_z.jpg",
                                 "https://farm2.staticflickr.com/1458/26425223582_03b4fcf02c_z.jpg",
                                 "https://farm2.staticflickr.com/1486/25915899284_9b3292134d_z.jpg",
                                 "https://farm2.staticflickr.com/1548/25923643953_bd49856fa1_z.jpg",
                                 "https://farm2.staticflickr.com/1540/25916726464_bf62837120_z.jpg",
                                 "https://farm2.staticflickr.com/1548/25911540274_95104bd63b_z.jpg",
                                 "https://farm2.staticflickr.com/1662/25918851094_6a3b8a6013_z.jpg",
                                 "https://farm2.staticflickr.com/1528/26424596842_e163a1a674_z.jpg",
                                 "https://farm2.staticflickr.com/1546/26530954205_a4e0805bc3_z.jpg",
                                 "https://farm2.staticflickr.com/1482/26256261620_8a36425e0e_z.jpg",
                                 "https://farm2.staticflickr.com/1582/26241761480_d7a0c37cfd_z.jpg",
                                 "https://farm2.staticflickr.com/1451/25923475883_5864529a07_z.jpg",
                                 "https://farm2.staticflickr.com/1532/25924433233_a2456303a5_z.jpg",
                                 "https://farm2.staticflickr.com/1717/26428339332_e99d506597_z.jpg",
                                 "https://farm2.staticflickr.com/1546/26527394275_2bd3aed5bf_z.jpg",
                                 "https://farm2.staticflickr.com/1658/26520381865_1661ca1488_z.jpg",
                                 "https://farm2.staticflickr.com/1710/26436053702_134fefff7b_z.jpg",
                                 "https://farm2.staticflickr.com/1582/25924197904_8f42d317b0_z.jpg",
                                 "https://farm2.staticflickr.com/1687/26451430271_cd1ea63b40_z.jpg",
                                 "https://farm2.staticflickr.com/1672/26521470435_7f62941b02_z.jpg",
                                 "https://farm2.staticflickr.com/1582/26428225112_849d87c873_z.jpg",
                                 "https://farm2.staticflickr.com/1569/26494829846_bbf1963f28_z.jpg",
                                 "https://farm2.staticflickr.com/1594/26435852322_7cfa9be77f_z.jpg",
                                 "https://farm2.staticflickr.com/1552/26248165260_89cc1aeb4d_z.jpg",
                                 "https://farm2.staticflickr.com/1451/26423865162_daf2588c2a_z.jpg",
                                 "https://farm2.staticflickr.com/1642/25908560674_4d93135c91_z.jpg",
                                 "https://farm2.staticflickr.com/1713/26256613450_ab0490479b_z.jpg",
                                 "https://farm2.staticflickr.com/1518/25922390034_4696297cde_z.jpg",
                                 "https://farm2.staticflickr.com/1513/25921673364_bbb82685b5_z.jpg",
                                 "https://farm2.staticflickr.com/1708/26493887596_9d0211025c_z.jpg",
                                 "https://farm2.staticflickr.com/1456/26437410412_b1c05d9f9f_z.jpg",
                                 "https://farm2.staticflickr.com/1476/26242793070_7fe6ea361c_z.jpg",
                                 "https://farm2.staticflickr.com/1717/26495500956_9dd8841bf9_z.jpg",
                                 "https://farm2.staticflickr.com/1712/26252556800_6fafced79a_z.jpg",
                                 "https://farm2.staticflickr.com/1444/25910903383_ce40d0293a_z.jpg",
                                 "https://farm2.staticflickr.com/1455/26253386590_32de7544ac_z.jpg",
                                 "https://farm2.staticflickr.com/1671/25911015774_d7d6fcf963_z.jpg",
                                 "https://farm2.staticflickr.com/1707/26526445165_9affb94e9d_z.jpg",
                                 "https://farm2.staticflickr.com/1519/26437091662_c6b5b15ccb_z.jpg",
                                 "https://farm2.staticflickr.com/1678/26421400072_dcf03d6154_z.jpg",
                                 "https://farm2.staticflickr.com/1476/26498469556_9a71429308_z.jpg",
                                 "https://farm2.staticflickr.com/1560/26243151660_dd1728e949_z.jpg",
                                 "https://farm2.staticflickr.com/1663/26421216542_9d9b2a5dc8_z.jpg",
                                 "https://farm2.staticflickr.com/1696/26258711380_12a771bea2_z.jpg",
                                 "https://farm2.staticflickr.com/1571/26253936720_b2752f5966_z.jpg",
                                 "https://farm2.staticflickr.com/1643/25914020143_937f66d26f_z.jpg",
                                 "https://farm2.staticflickr.com/1445/26495761946_5818bd7647_z.jpg",
                                 "https://farm2.staticflickr.com/1480/26495392006_fb11b5f7a6_z.jpg",
                                 "https://farm2.staticflickr.com/1677/26465074841_ca5befa0f1_z.jpg",
                                 "https://farm2.staticflickr.com/1452/26448303221_1081c3b15a_z.jpg",
                                 "https://farm2.staticflickr.com/1535/26518599125_d1ded344fa_z.jpg",
                                 "https://farm2.staticflickr.com/1458/26434328032_4da0eb922c_z.jpg",
                                 "https://farm2.staticflickr.com/1529/26461370381_aa0678ca0e_z.jpg",
                                 "https://farm2.staticflickr.com/1453/26523239995_17af87bdf5_z.jpg",
                                 "https://farm2.staticflickr.com/1459/25910701053_455454d315_z.jpg",
                                 "https://farm2.staticflickr.com/1469/26254808600_5f5ffd622c_z.jpg",
                                 "https://farm2.staticflickr.com/1587/25912787024_9c45a896a9_z.jpg",
                                 "https://farm2.staticflickr.com/1660/26252036660_b0e6c30067_z.jpg",
                                 "https://farm2.staticflickr.com/1680/26500326046_c299c3310e_z.jpg",
                                 "https://farm2.staticflickr.com/1546/26252716960_2246cdae84_z.jpg",
                                 "https://farm2.staticflickr.com/1650/26256225140_df3b495f06_z.jpg",
                                 "https://farm2.staticflickr.com/1586/25917167024_3a67f76db6_z.jpg",
                                 "https://farm2.staticflickr.com/1658/26450845721_fefc0828b4_z.jpg",
                                 "https://farm2.staticflickr.com/1459/25916087224_18ca4cc730_z.jpg",
                                 "https://farm2.staticflickr.com/1638/25916010813_78beff2d99_z.jpg",
                                 "https://farm2.staticflickr.com/1674/25915304843_1405db1ba2_z.jpg",
                                 "https://farm2.staticflickr.com/1522/26432077652_1fbaa2c1ac_z.jpg",
                                 "https://farm2.staticflickr.com/1507/26251353540_c2f76eb8fd_z.jpg",
                                 "https://farm2.staticflickr.com/1528/26457988781_655191a1a4_z.jpg",
                                 "https://farm2.staticflickr.com/1708/26526784745_e443f2fe44_z.jpg",
                                 "https://farm2.staticflickr.com/1551/26461384511_ae8a4c643e_z.jpg",
                                 "https://farm2.staticflickr.com/1591/25914531994_cb210d5673_z.jpg",
                                 "https://farm2.staticflickr.com/1509/26421121952_31978789ed_z.jpg",
                                 "https://farm2.staticflickr.com/1586/26530041355_6876f362a3_z.jpg",
                                 "https://farm2.staticflickr.com/1697/26254875930_06f8eb9931_z.jpg",
                                 "https://farm2.staticflickr.com/1447/25920907663_643d13831e_z.jpg",
                                 "https://farm2.staticflickr.com/1626/25916793023_0b5a3dd9e8_z.jpg",
                                 "https://farm2.staticflickr.com/1528/25916438883_e049472ce4_z.jpg",
                                 "https://farm2.staticflickr.com/1667/26492662036_3fe9ee4a72_z.jpg",
                                 "https://farm2.staticflickr.com/1717/26423723242_d74c921c19_z.jpg",
                                 "https://farm2.staticflickr.com/1623/25924789774_a996db9286_z.jpg"
]