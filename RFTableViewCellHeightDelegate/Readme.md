RFTableViewCellHeightDelegate
=======

RFTableViewCellHeightDelegate 是借助 Auto Layout 自动计算 table view cell 高度的插件。

Demo 见 https://github.com/RFUI/RFUI

特性
-----
* 无侵入式设计，无需子类 table view，不修改 dataSource，只需在 delegate 中添加至少一个方法；
* 支持多种，并且是任何种类的 cell，无需对 cell 做修改，这点完暴市面上见到的类似示例；
* 为性能做了尽可能的优化，比如会自动缓存计算好的 cell 高度；
* tableView 宽度改变时自动重算。


使用
-----

将 tableView delegate 设置成 RFTableViewCellHeightDelegate 实例，并设置其 delegate。

在代理中实现 `tableView:configureCell:forIndexPath:offscreenRendering:` 方法，其中 `isOffscreenRendering` 

```Objective-C
- (void)tableView:(UITableView *)tableView configureCell:(AudioCell *)cell forIndexPath:(NSIndexPath *)indexPath offscreenRendering:(BOOL)isOffscreenRendering {
    EntityModel *item = self.tableData[indexPath.row];
    cell.item = item;
    
    if (!isOffscreenRendering) {
        // 只在实际显示时执行昂贵的操作
        [cell prepareAudioPlayback];
    }
}
```

另外，强烈建议也实现 `tableView:cellReuseIdentifierForRowAtIndexPath:` 方法。实现后会打开对 cell 的缓存，不必每次计算 cell 高度都要向 dataSource 请求一个新的 cell。


特殊注意
-----
重载某些 cell 时，你可能需要手动刷新高度缓存。tableView 宽度改变时你不需要手动刷新高度缓存。

如果要在 cell 中使用多行的 UILabel，你可能必须要设置其 `preferredMaxLayoutWidth` 属性以便正确计算 label 的高度，考虑到 cell 的宽度是可能变化的，在其尺寸发生变化时修改 `preferredMaxLayout
idth` 是不错的选择，参考如下代码：

```Objective-C
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.preferredMaxLayoutWidth = bounds.size.width;
}
```

已知问题
-----
* iOS 6 下，滚动中修改 cell 的宽度（比如滚动时切换屏幕方向），可能会导致部分 cell 布局暂时异常（重用后可恢复正常），暂时没有解决方案。
* iOS 6 下，使用 `dequeueReusableCellWithIdentifier:forIndexPath:` 创建 cell 或当 tableView 尺寸变化时，tableView 的 contentSize 可能会异常，但可以通过调用 tableView 的 beginUpdates 和 endUpdates 方法刷新，参考代码如下：

```Objective-C
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    // On iOS 6, Table view’s contentSize may be wrong after frame changes.
    // !REF: http://stackoverflow.com/a/14429025
    if (RF_iOS7Before) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}
```
