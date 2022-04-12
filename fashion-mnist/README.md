# fashion-mnist

## 実験結果

|No.|Results|Base|Explanation|
|:---|:---|:---|:---|
|exp001|tr_loss=0.2291, tr_acc=0.9147<br>vd_loss=0.3016, vd_acc=0.8928<br>tt_loss=0.3439, tt_acc=0.8784|None|シンプルな全結合モデル|
|exp002|tr_loss=0.1428, tr_acc=0.9480<br>vd_loss=0.2434, vd_acc=0.9142<br>tt_loss=0.2675, tt_acc=0.9047|exp001|convモデル化|
|exp003|tr_loss=0.1789, tr_acc=0.9338<br>vd_loss=0.2620, vd_acc=0.9030<br>tt_loss=0.2749, tt_acc=0.9000|exp002|BN導入。層数が少ない場合は効果は低いか？|
|exp004|tr_loss=0.1402, tr_acc=0.9508<br>vd_loss=0.2006, vd_acc=0.9280<br>tt_loss=0.2088, tt_acc=0.9244|exp002|convを多層化。|

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

## 考察メモと改善案

- Data Augmentation
  - ちょっと試しながら効果があるやつを見極めたい。
  - 小さいので大胆に振る必要はないし、反転などが必要か微妙なところ。

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
