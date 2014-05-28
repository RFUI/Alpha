RFTableViewCellHeightDelegate
=======

RFTableViewCellHeightDelegate 是借助 Auto Layout 自动计算 table view cell 高度的插件。

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

```
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

重载某些 cell 时，你可能需要手动刷新高度缓存。tableView 宽度改变时不需要调用刷新方法。
