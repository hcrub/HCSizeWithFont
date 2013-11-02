HCSizeWithFont
==============

An iOS 7 sizeWithFont:constrainedToSize:lineBreakMode drop-in replacement

#### Usage
<pre><code>     [contentLabel setFrame:CGRectMake(kArticleXInset, 0, width,
                                      [text HCSizeWithFont:contentLabel.font
                                                      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                          lineBreakMode:NSLineBreakByWordWrapping].height)];
</code></pre>
