RFCoreDataAutoFetchTableViewPlugin
=====
RFCoreDataAutoFetchTableViewPlugin（以下简称“插件”）简化了在 tableView 中显示 core data 数据的工作，只需 20 多行代码即可完成数据获取及更新显示的全部工作，如下例所示：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.dataPlugin) {
        NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:CDENChannel];
        fr.sortDescriptors = @[];
        
        RFCoreDataAutoFetchTableViewPlugin *dp = [[RFCoreDataAutoFetchTableViewPlugin alloc] init];
        dp.master = self;
        dp.request = fr;
        dp.managedObjectContext = [DataStack sharedInstance].managedObjectContext;
        self.dataPlugin = dp;
    }
    
    self.dataPlugin.tableView = self.tableView;
}

- (UITableViewCell *)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin cellForRowAtIndexPath:(NSIndexPath *)indexPath managedObject:(NSManagedObject *)managedObject {
    ChannelListCell *cell = [plugin.tableView dequeueReusableCellWithClass:[ChannelListCell class]];
    cell.channel = (Channel *)managedObject;
    return cell;
}
```

内存管理注意
----
`UITableView` 会 retain 其插件，但如果为减少内存使用释放视图后，插件可能不会被正确重建。

建议的做法：让 view controller retain 插件，在 viewDidLoad 时设置插件的 `tableView` 属性为指定表格。

