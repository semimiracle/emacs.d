;; -*- coding: utf-8; lexical-binding: t; -*-

;; {{ make IME compatible with evil-mode
(defun evil-toggle-input-method ()
  "When input method is on, goto `evil-insert-state'."
  (interactive)

  ;; load IME when needed, less memory footprint
  (my-ensure 'pyim)

  ;; some guys don't use evil-mode at all
  (cond
   ((and (boundp 'evil-mode) evil-mode)
    ;; evil-mode
    (cond
     ((eq evil-state 'insert)
      (toggle-input-method))
     (t
      (evil-insert-state)
      (unless current-input-method
        (toggle-input-method))))
    (cond
     (current-input-method
      ;; evil-escape and pyim may conflict
      ;; @see https://github.com/redguardtoo/emacs.d/issues/629
      (evil-escape-mode -1)
      (message "IME on!"))
     (t
      (evil-escape-mode 1)
      (message "IME off!"))))
   (t
    ;; NOT evil-mode
    (toggle-input-method))))

(defun my-evil-insert-state-hack (orig-func &rest args)
  "Notify user IME status."
  (apply orig-func args)
  (if current-input-method (message "IME on!")))
(advice-add 'evil-insert-state :around #'my-evil-insert-state-hack)

(global-set-key (kbd "C-\\") 'evil-toggle-input-method)
;; }}

;; {{ pyim
(defvar my-pyim-directory "~/.eim"
  "The directory containing pyim dictionaries.")

(defvar my-pyim-enable-wubi-dict nil
  "Use Pinyin dictionary for Pyim IME.")

(with-eval-after-load 'pyim
  ;; use western punctuation
  (setq pyim-punctuation-dict nil)

  (setq default-input-method "pyim")

  (cond
   (my-pyim-enable-wubi-dict
    ;; load wubi dictionary
    (let* ((dir (file-name-directory
                 (locate-library "pyim-wbdict.el")))
           (file (concat dir "pyim-wbdict-v98.pyim")))
      (when (and (file-exists-p file) (featurep 'pyim))
        (setq pyim-dicts
              (list (list :name "wbdict-v98-elpa" :file file :elpa t))))))
   (t
    (setq pyim-fuzzy-pinyin-alist
          '(("en" "eng")
            ("in" "ing")))

    ;;  pyim-bigdict is recommended (20M). There are many useless words in pyim-greatdict which also slows
    ;;  down pyim performance
    ;; `curl -L http://tumashu.github.io/pyim-bigdict/pyim-bigdict.pyim.gz | zcat > ~/.eim/pyim-bigdict.pyim`

    ;; don's use shortcode2word
    (setq pyim-enable-shortcode nil)

    ;; use memory efficient pyim engine for pinyin ime
    (setq pyim-dcache-backend 'pyim-dregcache)

    ;; automatically load pinyin dictionaries "*.pyim" under "~/.eim/"
    (let* ((files (and (file-exists-p my-pyim-directory)
                       (directory-files-recursively my-pyim-directory "\.pyim$")))
           disable-basedict)
      (when (and files (> (length files) 0))
        (setq pyim-dicts
              (mapcar (lambda (f)
                        (list :name (file-name-base f) :file f))
                      files))
        ;; disable "basedict" if "pyim-bigdict" or "pyim-greatdict" or "pyim-another-dict" is used
        (dolist (f files)
          (when (or (string= "pyim-another-dict" (file-name-base f))
                    (string= "pyim-bigdict" (file-name-base f))
                    (string= "pyim-greatdict" (file-name-base f)))
            (setq disable-basedict t))))
      (unless disable-basedict (pyim-basedict-enable)))))

  ;; don't use tooltip
  (setq pyim-use-tooltip 'popup))
;; }}

;; {{ cal-china-x setup
(defun chinese-calendar (&optional arg)
  "Open Chinese Lunar calendar with ARG."
  (interactive "P")
  (unless (featurep 'cal-china-x) (local-require 'cal-china-x))
  (setq mark-holidays-in-calendar t)
  (setq cal-china-x-important-holidays cal-china-x-chinese-holidays)
  (setq cal-china-x-general-holidays '((holiday-lunar 1 15 "元宵节")))
  (setq calendar-holidays
        (append cal-china-x-important-holidays
                cal-china-x-general-holidays))
  (calendar arg))

(defun my-calendar-exit-hack (&optional arg)
  "Clean the cal-chinese-x setup."
  (advice-remove 'calendar-mark-holidays #'cal-china-x-mark-holidays))
(advice-add 'calendar-exit :before #'my-calendar-exit-hack)

(defconst my-chinese-pinyin-order-hash
  #s(hash-table size 30 test equal data (
"一" 375
"乙" 381
"二" 81
"十" 293
"丁" 72
"厂" 35
"七" 264
"卜" 20
"人" 278
"入" 278
"八" 6
"九" 145
"几" 136
"儿" 84
"了" 169
"力" 178
"乃" 218
"刀" 63
"又" 375
"三" 293
"于" 375
"干" 98
"亏" 166
"士" 312
"工" 105
"土" 330
"才" 22
"寸" 56
"下" 360
"大" 58
"丈" 405
"与" 375
"万" 350
"上" 293
"小" 360
"口" 160
"巾" 142
"山" 305
"千" 266
"乞" 264
"川" 45
"亿" 381
"个" 95
"勺" 307
"久" 145
"凡" 87
"及" 136
"夕" 361
"丸" 353
"么" 196
"广" 111
"亡" 354
"门" 196
"义" 381
"之" 391
"尸" 312
"弓" 105
"己" 136
"已" 381
"子" 391
"卫" 355
"也" 375
"女" 241
"飞" 89
"刃" 283
"习" 361
"叉" 32
"马" 196
"乡" 364
"丰" 91
"王" 350
"井" 143
"开" 150
"夫" 94
"天" 330
"无" 359
"元" 388
"专" 416
"云" 390
"扎" 402
"艺" 381
"木" 215
"五" 350
"支" 410
"厅" 342
"不" 5
"太" 330
"犬" 275
"区" 274
"历" 178
"尤" 386
"友" 386
"匹" 254
"车" 37
"巨" 146
"牙" 376
"屯" 348
"比" 14
"互" 127
"切" 269
"瓦" 351
"止" 410
"少" 293
"日" 278
"中" 391
"冈" 99
"贝" 11
"内" 223
"水" 293
"见" 138
"午" 359
"牛" 235
"手" 293
"毛" 201
"气" 264
"升" 311
"长" 35
"仁" 283
"什" 293
"片" 255
"仆" 262
"化" 128
"仇" 42
"币" 14
"仍" 284
"仅" 142
"斤" 142
"爪" 406
"反" 87
"介" 141
"父" 94
"从" 22
"今" 142
"凶" 369
"分" 85
"乏" 86
"公" 105
"仓" 26
"月" 389
"氏" 312
"勿" 359
"欠" 266
"风" 91
"丹" 61
"匀" 390
"乌" 359
"凤" 91
"勾" 106
"文" 350
"六" 186
"方" 85
"火" 134
"为" 350
"斗" 75
"忆" 381
"订" 72
"计" 136
"户" 127
"认" 283
"心" 367
"尺" 40
"引" 382
"丑" 42
"巴" 6
"孔" 159
"队" 78
"办" 8
"以" 375
"允" 390
"予" 387
"劝" 275
"双" 293
"书" 314
"幻" 130
"玉" 387
"刊" 153
"示" 293
"末" 196
"未" 355
"击" 136
"打" 59
"巧" 268
"正" 391
"扑" 262
"扒" 6
"功" 95
"扔" 284
"去" 274
"甘" 98
"世" 312
"古" 107
"节" 141
"本" 12
"术" 314
"可" 150
"丙" 19
"左" 428
"厉" 178
"右" 386
"石" 312
"布" 21
"龙" 188
"平" 259
"灭" 209
"轧" 96
"东" 74
"卡" 150
"北" 11
"占" 404
"业" 380
"旧" 145
"帅" 316
"归" 112
"且" 269
"旦" 61
"目" 215
"叶" 380
"甲" 137
"申" 310
"叮" 72
"电" 69
"号" 115
"田" 339
"由" 375
"史" 312
"只" 391
"央" 378
"兄" 369
"叼" 70
"叫" 135
"另" 185
"叨" 63
"叹" 333
"四" 293
"生" 311
"失" 312
"禾" 121
"丘" 273
"付" 94
"仗" 405
"代" 60
"仙" 363
"们" 196
"仪" 381
"白" 7
"仔" 393
"他" 330
"斥" 40
"瓜" 108
"乎" 127
"丛" 51
"令" 185
"用" 375
"甩" 316
"印" 382
"乐" 175
"句" 146
"匆" 51
"册" 28
"犯" 87
"外" 352
"处" 43
"冬" 74
"鸟" 230
"务" 359
"包" 5
"饥" 136
"主" 391
"市" 312
"立" 178
"闪" 305
"兰" 172
"半" 8
"汁" 410
"汇" 132
"头" 330
"汉" 118
"宁" 234
"穴" 373
"它" 330
"讨" 335
"写" 360
"让" 278
"礼" 178
"训" 374
"必" 5
"议" 381
"讯" 374
"记" 136
"永" 385
"司" 322
"尼" 227
"民" 210
"出" 31
"辽" 182
"奶" 218
"奴" 238
"加" 137
"召" 391
"皮" 254
"边" 15
"发" 85
"孕" 390
"圣" 311
"对" 58
"台" 332
"矛" 201
"纠" 145
"母" 196
"幼" 386
"丝" 322
"式" 312
"刑" 368
"动" 74
"扛" 99
"寺" 322
"吉" 136
"扣" 160
"考" 155
"托" 349
"老" 174
"执" 410
"巩" 105
"圾" 136
"扩" 168
"扫" 298
"地" 64
"扬" 378
"场" 35
"耳" 84
"共" 105
"芒" 200
"亚" 376
"芝" 410
"朽" 370
"朴" 256
"机" 136
"权" 275
"过" 95
"臣" 38
"再" 391
"协" 366
"西" 361
"压" 376
"厌" 377
"在" 391
"有" 375
"百" 7
"存" 56
"而" 81
"页" 380
"匠" 139
"夸" 162
"夺" 80
"灰" 132
"达" 59
"列" 183
"死" 293
"成" 39
"夹" 137
"轨" 112
"邪" 366
"划" 128
"迈" 198
"毕" 14
"至" 410
"此" 50
"贞" 408
"师" 312
"尘" 38
"尖" 138
"劣" 183
"光" 111
"当" 62
"早" 396
"吐" 345
"吓" 121
"虫" 41
"曲" 274
"团" 346
"同" 343
"吊" 70
"吃" 40
"因" 382
"吸" 361
"吗" 196
"屿" 387
"帆" 87
"岁" 327
"回" 132
"岂" 264
"刚" 99
"则" 391
"肉" 287
"网" 354
"年" 216
"朱" 413
"先" 360
"丢" 73
"舌" 308
"竹" 413
"迁" 266
"乔" 268
"伟" 355
"传" 45
"乒" 259
"乓" 249
"休" 370
"伍" 359
"伏" 94
"优" 375
"伐" 86
"延" 377
"件" 138
"任" 283
"伤" 293
"价" 137
"份" 90
"华" 115
"仰" 378
"仿" 88
"伙" 134
"伪" 355
"自" 391
"血" 360
"向" 364
"似" 312
"后" 126
"行" 119
"舟" 412
"全" 263
"会" 115
"杀" 303
"合" 121
"兆" 406
"企" 264
"众" 391
"爷" 380
"伞" 296
"创" 46
"肌" 136
"朵" 80
"杂" 392
"危" 355
"旬" 374
"旨" 410
"负" 94
"各" 101
"名" 211
"多" 58
"争" 409
"色" 299
"壮" 417
"冲" 41
"冰" 19
"庄" 417
"庆" 271
"亦" 381
"刘" 186
"齐" 264
"交" 140
"次" 50
"衣" 381
"产" 34
"决" 148
"充" 41
"妄" 354
"闭" 14
"问" 356
"闯" 46
"羊" 378
"并" 5
"关" 95
"米" 206
"灯" 66
"州" 412
"汗" 118
"污" 359
"江" 139
"池" 40
"汤" 334
"忙" 200
"兴" 368
"宇" 387
"守" 313
"宅" 403
"字" 391
"安" 2
"讲" 139
"军" 149
"许" 127
"论" 192
"农" 236
"讽" 91
"设" 308
"访" 88
"寻" 374
"那" 216
"迅" 374
"尽" 142
"导" 63
"异" 381
"孙" 328
"阵" 408
"阳" 378
"收" 313
"阶" 141
"阴" 382
"防" 88
"奸" 138
"如" 288
"妇" 94
"好" 115
"她" 330
"妈" 196
"戏" 361
"羽" 387
"观" 110
"欢" 130
"买" 198
"红" 125
"纤" 266
"级" 136
"约" 389
"纪" 136
"驰" 40
"巡" 374
"寿" 313
"弄" 236
"麦" 198
"形" 368
"进" 142
"戒" 141
"吞" 348
"远" 388
"违" 355
"运" 390
"扶" 94
"抚" 94
"坛" 333
"技" 136
"坏" 129
"扰" 281
"拒" 146
"找" 391
"批" 254
"扯" 37
"址" 410
"走" 423
"抄" 36
"坝" 6
"贡" 105
"攻" 105
"赤" 40
"折" 308
"抓" 414
"扮" 8
"抢" 267
"孝" 365
"均" 149
"抛" 250
"投" 344
"坟" 90
"抗" 154
"坑" 158
"坊" 88
"抖" 75
"护" 127
"壳" 156
"志" 391
"扭" 235
"块" 163
"声" 293
"把" 5
"报" 10
"却" 276
"劫" 141
"芽" 376
"花" 128
"芹" 270
"芬" 90
"苍" 26
"芳" 88
"严" 377
"芦" 190
"劳" 174
"克" 156
"苏" 325
"杆" 98
"杠" 99
"杜" 76
"材" 24
"村" 56
"杏" 368
"极" 136
"李" 178
"杨" 378
"求" 273
"更" 104
"束" 314
"豆" 75
"两" 181
"丽" 178
"医" 381
"辰" 38
"励" 178
"否" 93
"还" 117
"歼" 138
"来" 169
"连" 180
"步" 21
"坚" 138
"旱" 118
"盯" 72
"呈" 39
"时" 293
"吴" 359
"助" 413
"县" 363
"里" 178
"呆" 60
"园" 388
"旷" 165
"围" 355
"呀" 375
"吨" 79
"足" 424
"邮" 386
"男" 219
"困" 167
"吵" 36
"串" 45
"员" 375
"听" 330
"吩" 90
"吹" 47
"呜" 359
"吧" 5
"吼" 126
"别" 17
"岗" 99
"帐" 405
"财" 24
"针" 408
"钉" 72
"告" 100
"我" 350
"乱" 191
"利" 178
"秃" 345
"秀" 370
"私" 322
"每" 196
"兵" 5
"估" 107
"体" 330
"何" 121
"但" 58
"伸" 310
"作" 428
"伯" 20
"伶" 185
"佣" 385
"低" 67
"你" 216
"住" 413
"位" 355
"伴" 8
"身" 310
"皂" 90
"佛" 92
"近" 142
"彻" 37
"役" 381
"返" 87
"余" 387
"希" 361
"坐" 428
"谷" 107
"妥" 349
"含" 115
"邻" 184
"岔" 32
"肝" 98
"肚" 76
"肠" 35
"龟" 95
"免" 207
"狂" 165
"犹" 386
"角" 140
"删" 305
"条" 330
"卵" 191
"岛" 63
"迎" 383
"饭" 87
"饮" 382
"系" 136
"言" 377
"冻" 74
"状" 417
"亩" 215
"况" 165
"床" 46
"库" 150
"疗" 182
"应" 383
"冷" 177
"这" 391
"序" 371
"辛" 367
"弃" 264
"冶" 380
"忘" 354
"闲" 363
"间" 138
"闷" 204
"判" 248
"灶" 396
"灿" 25
"弟" 67
"汪" 354
"沙" 303
"汽" 264
"沃" 358
"泛" 87
"沟" 106
"没" 196
"沈" 293
"沉" 38
"怀" 129
"忧" 386
"快" 150
"完" 350
"宋" 323
"宏" 125
"牢" 174
"究" 145
"穷" 272
"灾" 393
"良" 181
"证" 409
"启" 264
"评" 259
"补" 21
"初" 43
"社" 308
"识" 312
"诉" 325
"诊" 408
"词" 50
"译" 381
"君" 149
"灵" 185
"即" 136
"层" 30
"尿" 230
"尾" 355
"迟" 40
"局" 146
"改" 97
"张" 391
"忌" 136
"际" 136
"陆" 186
"阿" 0
"陈" 38
"阻" 424
"附" 94
"妙" 208
"妖" 379
"妨" 88
"努" 238
"忍" 283
"劲" 142
"鸡" 136
"驱" 274
"纯" 48
"纱" 303
"纳" 217
"纲" 99
"驳" 20
"纵" 422
"纷" 90
"纸" 410
"纹" 356
"纺" 88
"驴" 194
"纽" 235
"奉" 91
"玩" 353
"环" 130
"武" 359
"青" 271
"责" 397
"现" 363
"表" 16
"规" 112
"抹" 197
"拢" 188
"拔" 6
"拣" 138
"担" 61
"坦" 333
"押" 376
"抽" 42
"拐" 109
"拖" 349
"拍" 247
"者" 391
"顶" 72
"拆" 33
"拥" 385
"抵" 67
"拘" 146
"势" 312
"抱" 10
"垃" 170
"拉" 170
"拦" 172
"拌" 8
"幸" 368
"招" 406
"坡" 260
"披" 254
"拨" 20
"择" 391
"抬" 332
"其" 136
"取" 274
"苦" 161
"若" 292
"茂" 201
"苹" 259
"苗" 208
"英" 375
"范" 87
"直" 410
"茄" 137
"茎" 143
"茅" 201
"林" 184
"枝" 410
"杯" 11
"柜" 112
"析" 361
"板" 8
"松" 323
"枪" 267
"构" 106
"杰" 141
"述" 293
"枕" 408
"丧" 293
"或" 134
"画" 128
"卧" 358
"事" 293
"刺" 50
"枣" 396
"雨" 387
"卖" 198
"矿" 165
"码" 197
"厕" 28
"奔" 12
"奇" 136
"奋" 90
"态" 332
"欧" 244
"垄" 188
"妻" 264
"轰" 125
"顷" 271
"转" 416
"斩" 138
"轮" 192
"软" 289
"到" 63
"非" 85
"叔" 314
"肯" 157
"齿" 40
"些" 360
"虎" 127
"虏" 190
"肾" 310
"贤" 363
"尚" 306
"旺" 354
"具" 146
"果" 114
"味" 355
"昆" 167
"国" 95
"昌" 35
"畅" 35
"明" 211
"易" 381
"昂" 3
"典" 69
"固" 107
"忠" 411
"咐" 94
"呼" 127
"鸣" 211
"咏" 385
"呢" 216
"岸" 2
"岩" 377
"帖" 341
"罗" 193
"帜" 410
"岭" 185
"凯" 152
"败" 7
"贩" 87
"购" 106
"图" 330
"钓" 70
"制" 410
"知" 410
"垂" 47
"牧" 215
"物" 359
"乖" 109
"刮" 108
"秆" 98
"和" 115
"季" 136
"委" 355
"佳" 137
"侍" 312
"供" 95
"使" 293
"例" 178
"版" 5
"侄" 410
"侦" 408
"侧" 28
"凭" 259
"侨" 268
"佩" 251
"货" 134
"依" 381
"的" 58
"迫" 260
"质" 410
"欣" 367
"征" 409
"往" 354
"爬" 246
"彼" 14
"径" 143
"所" 293
"舍" 293
"金" 142
"命" 211
"斧" 94
"爸" 6
"采" 24
"受" 293
"乳" 288
"贪" 333
"念" 228
"贫" 258
"肤" 94
"肺" 89
"肢" 410
"肿" 411
"胀" 405
"朋" 253
"股" 107
"肥" 89
"服" 94
"胁" 366
"周" 412
"昏" 133
"鱼" 387
"兔" 345
"狐" 127
"忽" 127
"狗" 95
"备" 11
"饰" 312
"饱" 10
"饲" 322
"变" 5
"京" 143
"享" 364
"店" 69
"夜" 375
"庙" 208
"府" 94
"底" 67
"剂" 136
"郊" 140
"废" 89
"净" 143
"盲" 200
"放" 85
"刻" 156
"育" 387
"闸" 402
"闹" 221
"郑" 409
"券" 275
"卷" 147
"单" 61
"炒" 36
"炊" 47
"炕" 154
"炎" 377
"炉" 190
"沫" 213
"浅" 266
"法" 85
"泄" 366
"河" 121
"沾" 404
"泪" 176
"油" 386
"泊" 20
"沿" 377
"泡" 250
"注" 413
"泻" 366
"泳" 385
"泥" 227
"沸" 89
"波" 20
"泼" 260
"泽" 397
"治" 410
"怖" 21
"性" 368
"怕" 246
"怜" 180
"怪" 109
"学" 373
"宝" 10
"宗" 422
"定" 72
"宜" 381
"审" 310
"宙" 412
"官" 110
"空" 150
"帘" 180
"实" 293
"试" 312
"郎" 173
"诗" 312
"肩" 138
"房" 88
"诚" 39
"衬" 38
"衫" 305
"视" 312
"话" 115
"诞" 61
"询" 374
"该" 95
"详" 364
"建" 138
"肃" 325
"录" 190
"隶" 178
"居" 146
"届" 141
"刷" 315
"屈" 274
"弦" 363
"承" 39
"孟" 205
"孤" 107
"陕" 305
"降" 139
"限" 363
"妹" 203
"姑" 107
"姐" 141
"姓" 368
"始" 312
"驾" 137
"参" 25
"艰" 138
"线" 363
"练" 180
"组" 424
"细" 361
"驶" 312
"织" 410
"终" 411
"驻" 413
"驼" 349
"绍" 307
"经" 143
"贯" 110
"奏" 423
"春" 48
"帮" 9
"珍" 408
"玻" 20
"毒" 76
"型" 368
"挂" 108
"封" 85
"持" 40
"项" 364
"垮" 162
"挎" 162
"城" 39
"挠" 221
"政" 409
"赴" 94
"赵" 406
"挡" 62
"挺" 330
"括" 168
"拴" 317
"拾" 312
"挑" 340
"指" 410
"垫" 69
"挣" 409
"挤" 136
"拼" 245
"挖" 351
"按" 2
"挥" 132
"挪" 240
"某" 214
"甚" 310
"革" 101
"荐" 138
"巷" 119
"带" 60
"草" 27
"茧" 138
"茶" 32
"荒" 131
"茫" 200
"荡" 62
"荣" 286
"故" 107
"胡" 127
"南" 219
"药" 379
"标" 16
"枯" 161
"柄" 19
"栋" 74
"相" 360
"查" 32
"柏" 7
"柳" 186
"柱" 413
"柿" 312
"栏" 172
"树" 314
"要" 375
"咸" 363
"威" 355
"歪" 352
"研" 377
"砖" 416
"厘" 178
"厚" 126
"砌" 264
"砍" 153
"面" 196
"耐" 218
"耍" 315
"牵" 266
"残" 25
"殃" 378
"轻" 271
"鸦" 376
"皆" 141
"背" 11
"战" 391
"点" 69
"临" 184
"览" 172
"竖" 314
"省" 311
"削" 365
"尝" 35
"是" 293
"盼" 248
"眨" 402
"哄" 125
"显" 363
"哑" 376
"冒" 201
"映" 383
"星" 368
"昨" 428
"畏" 355
"趴" 246
"胃" 355
"贵" 112
"界" 141
"虹" 125
"虾" 362
"蚁" 381
"思" 322
"蚂" 197
"虽" 293
"品" 245
"咽" 377
"骂" 197
"哗" 128
"咱" 394
"响" 364
"哈" 116
"咬" 379
"咳" 117
"哪" 217
"炭" 333
"峡" 362
"罚" 86
"贱" 138
"贴" 341
"骨" 107
"钞" 36
"钟" 391
"钢" 99
"钥" 379
"钩" 106
"卸" 366
"缸" 99
"拜" 7
"看" 150
"矩" 146
"怎" 391
"牲" 311
"选" 372
"适" 312
"秒" 208
"香" 364
"种" 411
"秋" 273
"科" 156
"重" 41
"复" 94
"竿" 98
"段" 77
"便" 15
"俩" 179
"贷" 60
"顺" 320
"修" 370
"保" 10
"促" 53
"侮" 359
"俭" 138
"俗" 325
"俘" 94
"信" 367
"皇" 131
"泉" 275
"鬼" 95
"侵" 270
"追" 418
"俊" 149
"盾" 79
"待" 60
"律" 194
"很" 115
"须" 371
"叙" 371
"剑" 138
"逃" 335
"食" 312
"盆" 252
"胆" 61
"胜" 311
"胞" 10
"胖" 249
"脉" 198
"勉" 207
"狭" 362
"狮" 312
"独" 76
"狡" 140
"狱" 387
"狠" 123
"贸" 201
"怨" 388
"急" 136
"饶" 281
"蚀" 312
"饺" 140
"饼" 19
"弯" 353
"将" 135
"奖" 139
"哀" 1
"亭" 342
"亮" 181
"度" 76
"迹" 136
"庭" 342
"疮" 46
"疯" 91
"疫" 381
"疤" 6
"姿" 421
"亲" 270
"音" 375
"帝" 67
"施" 312
"闻" 356
"阀" 86
"阁" 101
"差" 32
"养" 378
"美" 203
"姜" 139
"叛" 248
"送" 323
"类" 176
"迷" 206
"前" 266
"首" 293
"逆" 227
"总" 422
"炼" 180
"炸" 402
"炮" 250
"烂" 172
"剃" 338
"洁" 141
"洪" 125
"洒" 294
"浇" 140
"浊" 420
"洞" 74
"测" 28
"洗" 361
"活" 134
"派" 247
"洽" 265
"染" 279
"济" 136
"洋" 375
"洲" 412
"浑" 133
"浓" 236
"津" 142
"恒" 124
"恢" 132
"恰" 265
"恼" 221
"恨" 123
"举" 146
"觉" 140
"宣" 372
"室" 312
"宫" 105
"宪" 363
"突" 330
"穿" 45
"窃" 269
"客" 156
"冠" 110
"语" 387
"扁" 15
"袄" 4
"祖" 424
"神" 310
"祝" 413
"误" 359
"诱" 386
"说" 293
"诵" 323
"垦" 157
"退" 347
"既" 136
"屋" 359
"昼" 412
"费" 89
"陡" 75
"眉" 203
"孩" 117
"除" 43
"险" 363
"院" 388
"娃" 351
"姥" 174
"姨" 381
"姻" 382
"娇" 140
"怒" 238
"架" 137
"贺" 121
"盈" 383
"勇" 385
"怠" 60
"柔" 287
"垒" 176
"绑" 9
"绒" 286
"结" 141
"绕" 281
"骄" 140
"绘" 132
"给" 95
"络" 193
"骆" 193
"绝" 148
"绞" 140
"统" 343
"耕" 104
"耗" 120
"艳" 377
"泰" 332
"珠" 413
"班" 8
"素" 325
"蚕" 25
"顽" 353
"盏" 404
"匪" 89
"捞" 174
"栽" 393
"捕" 21
"振" 408
"载" 391
"赶" 98
"起" 264
"盐" 377
"捎" 307
"捏" 231
"埋" 198
"捉" 420
"捆" 167
"捐" 147
"损" 328
"都" 58
"哲" 407
"逝" 312
"捡" 138
"换" 130
"挽" 353
"热" 282
"恐" 159
"壶" 127
"挨" 1
"耻" 40
"耽" 61
"恭" 105
"莲" 180
"莫" 213
"荷" 121
"获" 134
"晋" 142
"恶" 81
"真" 408
"框" 150
"桂" 112
"档" 62
"桐" 343
"株" 413
"桥" 268
"桃" 335
"格" 101
"校" 140
"核" 121
"样" 378
"根" 95
"索" 329
"哥" 101
"速" 325
"逗" 75
"栗" 178
"配" 251
"翅" 40
"辱" 288
"唇" 48
"夏" 362
"础" 43
"破" 260
"原" 388
"套" 335
"逐" 413
"烈" 183
"殊" 314
"顾" 95
"轿" 140
"较" 140
"顿" 79
"毙" 14
"致" 410
"柴" 33
"桌" 420
"虑" 194
"监" 138
"紧" 142
"党" 62
"晒" 304
"眠" 207
"晓" 365
"鸭" 376
"晃" 131
"晌" 306
"晕" 390
"蚊" 356
"哨" 307
"哭" 161
"恩" 81
"唤" 130
"啊" 0
"唉" 1
"罢" 6
"峰" 91
"圆" 388
"贼" 391
"贿" 132
"钱" 266
"钳" 266
"钻" 425
"铁" 341
"铃" 185
"铅" 266
"缺" 276
"氧" 378
"特" 336
"牺" 361
"造" 391
"乘" 39
"敌" 67
"秤" 39
"租" 424
"积" 136
"秧" 378
"秩" 410
"称" 38
"秘" 206
"透" 330
"笔" 14
"笑" 360
"笋" 328
"债" 403
"借" 141
"值" 391
"倚" 381
"倾" 271
"倒" 63
"倘" 334
"俱" 146
"倡" 35
"候" 126
"俯" 94
"倍" 11
"倦" 147
"健" 138
"臭" 42
"射" 308
"躬" 105
"息" 361
"徒" 345
"徐" 371
"舰" 138
"舱" 26
"般" 8
"航" 119
"途" 345
"拿" 216
"爹" 71
"爱" 1
"颂" 323
"翁" 357
"脆" 55
"脂" 410
"胸" 369
"胳" 101
"脏" 395
"胶" 140
"脑" 221
"狸" 178
"狼" 173
"逢" 91
"留" 186
"皱" 412
"饿" 81
"恋" 180
"桨" 139
"浆" 139
"衰" 316
"高" 95
"席" 361
"准" 419
"座" 428
"脊" 136
"症" 409
"病" 19
"疾" 136
"疼" 337
"疲" 254
"效" 365
"离" 178
"唐" 334
"资" 421
"凉" 181
"站" 404
"剖" 261
"竞" 143
"部" 21
"旁" 249
"旅" 194
"畜" 43
"阅" 389
"羞" 370
"瓶" 259
"拳" 275
"粉" 90
"料" 182
"益" 381
"兼" 138
"烤" 155
"烘" 125
"烦" 87
"烧" 307
"烛" 413
"烟" 377
"递" 67
"涛" 335
"浙" 407
"涝" 174
"酒" 145
"涉" 308
"消" 365
"浩" 120
"海" 115
"涂" 345
"浴" 387
"浮" 94
"流" 186
"润" 291
"浪" 173
"浸" 142
"涨" 405
"烫" 334
"涌" 385
"悟" 359
"悄" 268
"悔" 132
"悦" 389
"害" 117
"宽" 164
"家" 137
"宵" 365
"宴" 377
"宾" 18
"窄" 403
"容" 286
"宰" 393
"案" 2
"请" 263
"朗" 173
"诸" 413
"读" 76
"扇" 305
"袜" 351
"袖" 370
"袍" 250
"被" 5
"祥" 364
"课" 156
"谁" 293
"调" 70
"冤" 388
"谅" 181
"谈" 333
"谊" 381
"剥" 10
"恳" 157
"展" 404
"剧" 146
"屑" 366
"弱" 292
"陵" 185
"陶" 335
"陷" 363
"陪" 251
"娱" 387
"娘" 229
"通" 330
"能" 225
"难" 219
"预" 387
"桑" 297
"绢" 147
"绣" 370
"验" 377
"继" 136
"球" 273
"理" 178
"捧" 253
"堵" 76
"描" 208
"域" 387
"掩" 377
"捷" 141
"排" 245
"掉" 70
"堆" 78
"推" 347
"掀" 363
"授" 313
"教" 140
"掏" 335
"掠" 195
"培" 251
"接" 141
"控" 159
"探" 333
"据" 146
"掘" 148
"职" 410
"基" 136
"著" 413
"勒" 175
"黄" 131
"萌" 200
"萝" 193
"菌" 149
"菜" 24
"萄" 335
"菊" 146
"萍" 259
"菠" 20
"营" 383
"械" 366
"梦" 205
"梢" 307
"梅" 203
"检" 138
"梳" 314
"梯" 338
"桶" 343
"救" 145
"副" 94
"票" 245
"戚" 264
"爽" 293
"聋" 188
"袭" 361
"盛" 39
"雪" 360
"辅" 94
"辆" 181
"虚" 371
"雀" 276
"堂" 334
"常" 35
"匙" 40
"晨" 38
"睁" 409
"眯" 206
"眼" 377
"悬" 372
"野" 380
"啦" 170
"晚" 353
"啄" 412
"距" 146
"跃" 389
"略" 195
"蛇" 293
"累" 176
"唱" 35
"患" 130
"唯" 355
"崖" 376
"崭" 404
"崇" 41
"圈" 147
"铜" 330
"铲" 34
"银" 382
"甜" 339
"梨" 178
"犁" 178
"移" 381
"笨" 12
"笼" 188
"笛" 67
"符" 94
"第" 67
"敏" 210
"做" 391
"袋" 60
"悠" 386
"偿" 35
"偶" 244
"偷" 344
"您" 233
"售" 313
"停" 342
"偏" 255
"假" 137
"得" 58
"衔" 363
"盘" 248
"船" 45
"斜" 366
"盒" 121
"鸽" 101
"悉" 361
"欲" 387
"彩" 24
"领" 185
"脚" 140
"脖" 20
"脸" 180
"脱" 349
"象" 364
"够" 95
"猜" 24
"猪" 413
"猎" 183
"猫" 201
"猛" 205
"馅" 363
"馆" 110
"凑" 52
"减" 138
"毫" 120
"麻" 196
"痒" 378
"痕" 123
"廊" 173
"康" 154
"庸" 385
"鹿" 190
"盗" 63
"章" 405
"竟" 143
"商" 306
"族" 424
"旋" 372
"望" 354
"率" 194
"着" 391
"盖" 97
"粘" 228
"粗" 53
"粒" 178
"断" 77
"剪" 138
"兽" 313
"清" 271
"添" 339
"淋" 184
"淹" 377
"渠" 274
"渐" 138
"混" 133
"渔" 387
"淘" 335
"液" 380
"淡" 61
"深" 310
"婆" 260
"梁" 181
"渗" 310
"情" 271
"惜" 361
"惭" 25
"悼" 63
"惧" 146
"惕" 338
"惊" 143
"惨" 25
"惯" 110
"寇" 160
"寄" 136
"宿" 325
"窑" 140
"密" 206
"谋" 214
"谎" 131
"祸" 134
"谜" 203
"逮" 60
"敢" 98
"屠" 345
"弹" 61
"随" 327
"蛋" 61
"隆" 188
"隐" 382
"婚" 133
"婶" 310
"颈" 104
"绩" 136
"绪" 371
"续" 371
"骑" 264
"绳" 311
"维" 355
"绵" 207
"绸" 42
"绿" 194
"琴" 270
"斑" 8
"替" 338
"款" 164
"堪" 153
"搭" 59
"塔" 331
"越" 375
"趁" 38
"趋" 274
"超" 36
"提" 67
"堤" 67
"博" 20
"揭" 141
"喜" 361
"插" 32
"揪" 145
"搜" 293
"煮" 413
"援" 388
"裁" 24
"搁" 101
"搂" 189
"搅" 140
"握" 350
"揉" 287
"斯" 322
"期" 264
"欺" 264
"联" 180
"散" 296
"惹" 282
"葬" 395
"葛" 101
"董" 74
"葡" 262
"敬" 143
"葱" 51
"落" 170
"朝" 36
"辜" 107
"葵" 166
"棒" 9
"棋" 264
"植" 410
"森" 293
"椅" 381
"椒" 140
"棵" 156
"棍" 113
"棉" 207
"棚" 253
"棕" 422
"惠" 132
"惑" 134
"逼" 14
"厨" 43
"厦" 303
"硬" 383
"确" 276
"雁" 377
"殖" 410
"裂" 183
"雄" 369
"暂" 394
"雅" 376
"辈" 11
"悲" 11
"紫" 421
"辉" 132
"敞" 35
"赏" 306
"掌" 405
"晴" 271
"暑" 314
"最" 391
"量" 181
"喷" 252
"晶" 143
"喇" 170
"遇" 387
"喊" 118
"景" 143
"践" 138
"跌" 71
"跑" 245
"遗" 381
"蛙" 351
"蛛" 413
"蜓" 342
"喝" 121
"喂" 355
"喘" 45
"喉" 126
"幅" 94
"帽" 201
"赌" 76
"赔" 251
"黑" 122
"铸" 413
"铺" 262
"链" 180
"销" 365
"锁" 329
"锄" 43
"锅" 114
"锈" 370
"锋" 91
"锐" 290
"短" 77
"智" 410
"毯" 333
"鹅" 81
"剩" 311
"稍" 307
"程" 39
"稀" 361
"税" 319
"筐" 165
"等" 66
"筑" 413
"策" 28
"筛" 304
"筒" 343
"答" 59
"筋" 142
"筝" 409
"傲" 4
"傅" 94
"牌" 247
"堡" 10
"集" 136
"焦" 140
"傍" 9
"储" 43
"奥" 4
"街" 141
"惩" 39
"御" 387
"循" 374
"艇" 342
"舒" 314
"番" 87
"释" 293
"禽" 270
"腊" 170
"脾" 254
"腔" 267
"鲁" 190
"猾" 128
"猴" 126
"然" 278
"馋" 34
"装" 417
"蛮" 199
"就" 145
"痛" 343
"童" 343
"阔" 168
"善" 305
"羡" 363
"普" 262
"粪" 90
"尊" 427
"道" 63
"曾" 30
"焰" 377
"港" 99
"湖" 127
"渣" 402
"湿" 312
"温" 356
"渴" 156
"滑" 128
"湾" 353
"渡" 76
"游" 386
"滋" 421
"溉" 97
"愤" 90
"慌" 131
"惰" 80
"愧" 166
"愉" 387
"慨" 152
"割" 101
"寒" 118
"富" 94
"窜" 54
"窝" 358
"窗" 46
"遍" 15
"裕" 387
"裤" 161
"裙" 277
"谢" 366
"谣" 379
"谦" 266
"属" 314
"屡" 194
"强" 139
"粥" 387
"疏" 314
"隔" 101
"隙" 361
"絮" 371
"嫂" 298
"登" 66
"缎" 77
"缓" 130
"编" 15
"骗" 245
"缘" 388
"瑞" 278
"魂" 133
"肆" 322
"摄" 308
"摸" 213
"填" 339
"搏" 20
"塌" 331
"鼓" 107
"摆" 7
"携" 366
"搬" 8
"摇" 379
"搞" 95
"塘" 334
"摊" 333
"蒜" 326
"勤" 270
"鹊" 276
"蓝" 172
"墓" 215
"幕" 215
"蓬" 253
"蓄" 371
"蒙" 205
"蒸" 409
"献" 363
"禁" 142
"楚" 43
"想" 360
"槐" 129
"榆" 387
"楼" 189
"概" 97
"赖" 171
"酬" 42
"感" 98
"碍" 1
"碑" 11
"碎" 327
"碰" 253
"碗" 353
"碌" 186
"雷" 176
"零" 185
"雾" 359
"雹" 10
"输" 314
"督" 76
"龄" 185
"鉴" 138
"睛" 143
"睡" 293
"睬" 24
"鄙" 14
"愚" 387
"暖" 239
"盟" 205
"歇" 366
"暗" 2
"照" 406
"跨" 162
"跳" 340
"跪" 112
"路" 190
"跟" 95
"遣" 266
"蛾" 81
"蜂" 91
"嗓" 297
"置" 410
"罪" 426
"罩" 406
"错" 57
"锡" 361
"锣" 193
"锤" 47
"锦" 142
"键" 138
"锯" 146
"矮" 1
"辞" 50
"稠" 42
"愁" 42
"筹" 42
"签" 266
"简" 138
"毁" 132
"舅" 145
"鼠" 314
"催" 55
"傻" 303
"像" 364
"躲" 80
"微" 355
"愈" 387
"遥" 379
"腰" 379
"腥" 368
"腹" 94
"腾" 337
"腿" 347
"触" 43
"解" 141
"酱" 139
"痰" 333
"廉" 180
"新" 360
"韵" 390
"意" 381
"粮" 181
"数" 314
"煎" 138
"塑" 325
"慈" 50
"煤" 203
"煌" 131
"满" 199
"漠" 213
"源" 375
"滤" 194
"滥" 172
"滔" 335
"溪" 361
"溜" 186
"滚" 113
"滨" 18
"粱" 181
"滩" 333
"慎" 293
"誉" 387
"塞" 295
"谨" 142
"福" 94
"群" 277
"殿" 69
"辟" 14
"障" 405
"嫌" 363
"嫁" 137
"叠" 71
"缝" 91
"缠" 34
"静" 143
"碧" 14
"璃" 178
"墙" 267
"撇" 257
"嘉" 137
"摧" 55
"截" 141
"誓" 312
"境" 143
"摘" 403
"摔" 316
"聚" 146
"蔽" 14
"慕" 215
"暮" 215
"蔑" 209
"模" 196
"榴" 186
"榜" 9
"榨" 402
"歌" 101
"遭" 396
"酷" 161
"酿" 229
"酸" 326
"磁" 50
"愿" 388
"需" 360
"弊" 14
"裳" 35
"颗" 156
"嗽" 314
"蜻" 271
"蜡" 170
"蝇" 383
"蜘" 410
"赚" 416
"锹" 268
"锻" 77
"舞" 359
"稳" 356
"算" 293
"箩" 193
"管" 95
"僚" 182
"鼻" 14
"魄" 260
"貌" 201
"膜" 213
"膊" 20
"膀" 9
"鲜" 363
"疑" 381
"馒" 199
"裹" 114
"敲" 268
"豪" 120
"膏" 100
"遮" 407
"腐" 94
"瘦" 313
"辣" 170
"竭" 141
"端" 77
"旗" 264
"精" 143
"歉" 266
"熄" 361
"熔" 286
"漆" 264
"漂" 256
"漫" 199
"滴" 67
"演" 377
"漏" 189
"慢" 196
"寨" 403
"赛" 295
"察" 32
"蜜" 206
"谱" 262
"嫩" 224
"翠" 55
"熊" 369
"凳" 66
"骡" 193
"缩" 329
"慧" 132
"撕" 322
"撒" 294
"趣" 274
"趟" 334
"撑" 39
"播" 20
"撞" 417
"撤" 37
"增" 400
"聪" 51
"鞋" 366
"蕉" 140
"蔬" 314
"横" 124
"槽" 27
"樱" 383
"橡" 364
"飘" 245
"醋" 53
"醉" 426
"震" 408
"霉" 203
"瞒" 199
"题" 338
"暴" 5
"瞎" 362
"影" 383
"踢" 338
"踏" 331
"踩" 24
"踪" 422
"蝶" 71
"蝴" 127
"嘱" 413
"墨" 213
"镇" 408
"靠" 155
"稻" 63
"黎" 178
"稿" 100
"稼" 137
"箱" 364
"箭" 138
"篇" 255
"僵" 139
"躺" 334
"僻" 254
"德" 64
"艘" 324
"膝" 361
"膛" 334
"熟" 314
"摩" 213
"颜" 377
"毅" 381
"糊" 127
"遵" 427
"潜" 266
"潮" 36
"懂" 74
"额" 81
"慰" 355
"劈" 254
"操" 27
"燕" 377
"薯" 314
"薪" 367
"薄" 10
"颠" 69
"橘" 146
"整" 409
"融" 286
"醒" 368
"餐" 25
"嘴" 426
"蹄" 338
"器" 264
"赠" 400
"默" 213
"镜" 143
"赞" 394
"篮" 172
"邀" 379
"衡" 124
"膨" 253
"雕" 70
"磨" 213
"凝" 234
"辨" 15
"辩" 15
"糖" 334
"糕" 100
"燃" 279
"澡" 396
"激" 136
"懒" 172
"壁" 14
"避" 14
"缴" 140
"戴" 60
"擦" 23
"鞠" 146
"藏" 26
"霜" 318
"霞" 362
"瞧" 268
"蹈" 63
"螺" 193
"穗" 327
"繁" 87
"辫" 15
"赢" 383
"糟" 396
"糠" 154
"燥" 396
"臂" 14
"翼" 381
"骤" 412
"鞭" 15
"覆" 94
"蹦" 13
"镰" 180
"翻" 85
"鹰" 383
"警" 143
"攀" 248
"蹲" 79
"颤" 34
"瓣" 8
"爆" 10
"疆" 139
"壤" 280
"耀" 379
"躁" 396
"嚼" 140
"嚷" 280
"籍" 136
"魔" 213
"灌" 110
"蠢" 48
"霸" 6
"露" 189
"囊" 220
"罐" 110)))

(defun my-chinese-compare (w1 w2)
  "Compare Chinese word W2 and W3 by pinyin."
  (let ((i 0)
        (max-len (min (length w1) (length w2)))
        v1 v2
        break
        rlt)

    (while (and (not break) (< i max-len))
      (setq v1 (gethash (substring-no-properties w1 i (1+ i)) my-chinese-pinyin-order-hash 9999))
      (setq v2 (gethash (substring-no-properties w2 i (1+ i)) my-chinese-pinyin-order-hash 9999))
      (unless (eq v1 v2)
        (setq rlt (< v1 v2))
        (setq break t))
      (setq i (1+ i)))

    (cond
     ((eq i max-len)
      (eq max-len (length w1)))
     (t
      rlt))))

(defun my-chinese-sort-word-list (word-list)
  (when word-list
    (sort word-list #'my-chinese-compare)))

;; (message "test: %s" (my-chinese-sort-word-list '("小明" "小红" "张三" "李四" "王二" "大李" "古力娜扎" "迪丽热巴")))
;; }}
(provide 'init-chinese)
