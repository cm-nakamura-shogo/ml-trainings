# fashion-mnist

## 実験結果

- exp1xx
  - 安定化対応対応後
  - 安定化としては、regularizerと10回試行の統計量計算を実施した。

|No.|loss(tr,vd,tt)|acc.(tr,vd,tt)|Base|Explanation|
|:---|:---|:---|:---|:---|
|exp102|0.3548±0.0098, 0.3321～0.3656<br>0.3707±0.0066, 0.3577～0.3795<br>0.3967±0.0056, 0.3837～0.4062|0.9134±0.0037, 0.9099～0.9219<br>0.9073±0.0038, 0.9029～0.9147<br>0.8970±0.0023, 0.8929～0.9017|exp101|conv化|
|exp103|0.2864±0.0221, 0.2530～0.3159<br>0.3328±0.0112, 0.3219～0.3591<br>0.3582±0.0122, 0.3437～0.3869|0.9309±0.0088, 0.9180～0.9466<br>0.9139±0.0047, 0.9046～0.9208<br>0.9042±0.0055, 0.8917～0.9125|exp102|bn導入|
|exp104|0.2144±0.0275, 0.1817～0.2754<br>0.3694±0.0131, 0.3552～0.4057<br>0.3952±0.0137, 0.3827～0.4342|0.9801±0.0073, 0.9676～0.9904<br>0.9208±0.0025, 0.9172～0.9246<br>0.9127±0.0022, 0.9079～0.9161|exp103|batchsize 32->64<br>learning rate 0.001->0.0001|
|exp105|0.2139±0.0292, 0.1792～0.2814<br>0.3734±0.0123, 0.3614～0.4066<br>0.4004±0.0133, 0.3883～0.4379|0.9794±0.0086, 0.9583～0.9891<br>0.9204±0.0022, 0.9166～0.9245<br>0.9114±0.0021, 0.9079～0.9150|exp104|augmentation用の実装対応|

- exp0xx
  - 安定化対策前

|No.|Results|Base|Explanation|
|:---|:---|:---|:---|
|exp001|tr_loss=0.2291, tr_acc=0.9147<br>vd_loss=0.3016, vd_acc=0.8928<br>tt_loss=0.3439, tt_acc=0.8784|None|シンプルな全結合モデル|
|exp002|tr_loss=0.1428, tr_acc=0.9480<br>vd_loss=0.2434, vd_acc=0.9142<br>tt_loss=0.2675, tt_acc=0.9047|exp001|convモデル化|
|exp003|tr_loss=0.1789, tr_acc=0.9338<br>vd_loss=0.2620, vd_acc=0.9030<br>tt_loss=0.2749, tt_acc=0.9000|exp002|BN導入。層数が少ない場合は効果は低いか？|
|exp004|tr_loss=0.1402, tr_acc=0.9508<br>vd_loss=0.2006, vd_acc=0.9280<br>tt_loss=0.2088, tt_acc=0.9244|exp002|convを多層化。|
|exp005|tr_loss=0.1701, tr_acc=0.9366<br>vd_loss=0.2045, vd_acc=0.9251<br>tt_loss=0.2262, tt_acc=0.9181|exp004|colab対応。|
|exp006|tr_loss=0.1048, tr_acc=0.9615<br>vd_loss=0.2021, vd_acc=0.9322<br>tt_loss=0.2086, tt_acc=0.9266|exp005|data augmentationでzoom_rangeを有効化|
|exp007|tr_loss=0.1224, tr_acc=0.9591<br>vd_loss=0.1897, vd_acc=0.9348<br>tt_loss=0.2024, tt_acc=0.9328|exp006|mixup|
|exp008|tr_loss=0.1038, tr_acc=0.9652<br>vd_loss=0.2006, vd_acc=0.9316<br>tt_loss=0.2082, tt_acc=0.9279|exp007|random erase|

## 実装説明

### exp001-simple-dense-model

- そのままのシンプルな全結合モデル。
  - kerasではdense層が全結合層である。

- ほぼほぼ、kerasの公式実装通りである。
  - [https://www.tensorflow.org/tutorials/keras/classification](https://www.tensorflow.org/tutorials/keras/classification)

- 以下は追加している。
  - trainをtrainとvalidに分割する。
  - validデータによるearly_stoppingコールバックの実装。
  - 結果を安定させるため`tf.keras.utils.set_random_seed`を設定。

### exp002-conv-model

- 画像処理にはconvが相性が良いので、convに置き換え。
  - 相性が良いのは、位置情報のコンテキストを維持したまま特徴量計算が可能なため。
  - 全結合では位置情報のコンテキストが消える。ノードの順番に意味がなくなるため。

- ソースはMNIST向けから流用した。
  - https://www.tensorflow.org/tutorials/images/intro_to_cnns?hl=ja

### exp003-bach-normalization

- Batch Normalizationはデファクトスタンダードな手法なので有効にしたが、あまり性能向上しなかった。

- 層数が少ない場合は効果が小さいのかもしれない。また後で試す。

### exp004-conv-model-6

- 多層化を試してみる。単純にconv3x3を増やす。もともとは3層だったので倍くらい。
  - 多層化できるように、`padding='same'`に設定する。

- 層数を増やすと同時にチャンネル数も増やしてみる。
  - EfficientNet的には、同時にスケールさせた方が良いはず。

- ついでに後段のDenseを削除して、Global Average Poolingにより、FCN(Fully Convolutional Network)構成にした。

### exp005-colab

- colab実行に対応。
  
### exp006-data-augmentation

- データ拡張を実装。kerasの`ImageDataGenerator`を使用。
  - https://keras.io/ja/preprocessing/image/

- 効果があったのは、`zoom_range`のみであったため、こちらのみ有効化

### exp007-mixup

- データ拡張としてmixupを導入。

- `ImageDataGenerator`に未実装であったため、継承して実装。

### exp008-random-erase

- データ拡張としてrandom-eraseを導入した。
- 再現性に悩まされており、改善には至っていない。

## 考察メモと改善案

- Data Augmentation
  - ちょっと試しながら効果があるやつを見極めたい。
  - 小さいので大胆に振る必要はないし、反転などが必要か微妙なところ。

- kernel regularizer
  - 過学習気味なので、L2正則化してみる。

- Batch Normalizationの再検証
  - 本来は効果があるはずなのだが

- より複雑なネットワークの構成(有名な論文の知見)
  - ResNet
  - DenseNet
  - depthwise
  - CSPNet
  - SE_block

- 活性化関数
  - Mish試したけどあまり効果なかった。
  - 色々やった方が良いけど、後回しの最後の詰めの部分かな。

- Cross Validation
  - 学習に時間がかかるので、過学習があまりにも大きい場合以外はやらない方針。

- 多層化
  - あまりやらなくていいかも。
  - 入力の画素数はImageNetに比べて小さい(ImageNetは224x224だが、このお題は28x28と小さいので)

## 参考

- 公式はここ
  - [https://github.com/zalandoresearch/fashion-mnist/blob/master/README.ja.md](https://github.com/zalandoresearch/fashion-mnist/blob/master/README.ja.md)

- kerasで始める場合はこちらを参照
  - [https://www.tensorflow.org/tutorials/keras/classification](https://www.tensorflow.org/tutorials/keras/classification)
