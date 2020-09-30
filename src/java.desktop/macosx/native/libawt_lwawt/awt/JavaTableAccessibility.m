// Copyright 2000-2020 JetBrains s.r.o. Use of this source code is governed by the Apache 2.0 license that can be found in the LICENSE file.

#include "jni.h"
#import <JavaNativeFoundation/JavaNativeFoundation.h>
#import "sun_lwawt_macosx_CAccessibility.h"
#import "JavaRowAccessibility.h"
#import "JavaAccessibilityAction.h"
#import "JavaAccessibilityUtilities.h"
#import "JavaTextAccessibility.h"
#import "JavaTableAccessibility.h"
#import "JavaCellAccessibility.h"
#import "ThreadUtilities.h"

@implementation JavaTableAccessibility

- (NSString *)getPlatformAxElementClassName {
    return @"PlatformAxTable";
}

@end

@implementation PlatformAxTable

- (NSArray *)accessibilityChildren {
        NSArray *children = [super accessibilityChildren];
    if (children == NULL) {
        return NULL;
    }
     int rowCount = 0, y = 0;
     for (id cell in children) {
     if (y != [cell accessibilityFrame].origin.y) {
     rowCount += 1;
     y = [cell accessibilityFrame].origin.y;
     }
     }
        printf("Размеры таблицы %d на %d\n", [self accessibleRowCount], [self accessibleColCount]);
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:rowCount];
    int k = 0, cellCount = [children count] / rowCount;
    for (int i = 0; i < rowCount; i++) {
        NSMutableArray *cells = [NSMutableArray arrayWithCapacity:cellCount];
        NSMutableString *a11yName = @"row";
        CGFloat width = 0;
        for (int j = 0; j < cellCount; j++) {
            [cells addObject:[children objectAtIndex:k]];
            width += [[children objectAtIndex:k] accessibilityFrame].size.width;
            k += 1;
        }
        CGPoint point = [[cells objectAtIndex:0] accessibilityFrame].origin;
        CGFloat height = [[cells objectAtIndex:0] accessibilityFrame].size.height;
        NSAccessibilityElement *a11yRow = [NSAccessibilityElement accessibilityElementWithRole:NSAccessibilityRowRole frame:NSRectFromCGRect(CGRectMake(point.x, point.y, width, height)) label:a11yName parent:self];
        [a11yRow setAccessibilityChildren:cells];
        for (JavaCellAccessibility *cell in cells) [cell setAccessibilityParent:a11yRow];
        [rows addObject:a11yRow];
    }
    return rows;
}

- (NSArray *)accessibilityRows {
    return [self accessibilityChildren];
}
/*
- (nullable NSArray<id<NSAccessibilityRow>> *)accessibilitySelectedRows {
    return [self accessibilitySelectedChildren];
}
 */

- (NSString *)accessibilityLabel {
    if (([super accessibilityLabel] == NULL) || [[super accessibilityLabel] isEqualToString:@""]) {
        return @"Table";
    }
    return [super accessibilityLabel];
}

/*
- (nullable NSArray<id<NSAccessibilityRow>> *)accessibilityVisibleRows;
- (nullable NSArray *)accessibilityColumns;
- (nullable NSArray *)accessibilityVisibleColumns;
- (nullable NSArray *)accessibilitySelectedColumns;

- (nullable NSArray *)accessibilitySelectedCells;
- (nullable NSArray *)accessibilityVisibleCells;
- (nullable NSArray *)accessibilityRowHeaderUIElements;
- (nullable NSArray *)accessibilityColumnHeaderUIElements;
 */

- (NSRect)accessibilityFrame {
    return [super accessibilityFrame];
}

- (id)accessibilityParent {
    return [super accessibilityParent];
}

- (int)accessibleRowCount {
    JNIEnv *env = [ThreadUtilities getJNIEnv];
    jclass clsAJT = (*env)->GetObjectClass(env, [self accessibleContext]);
    JNFClassInfo clsAJTInfo;
    clsAJTInfo.name = "javax.swing.JTable$AccessibleJTable";
    clsAJTInfo.cls = clsAJT;
    JNF_MEMBER_CACHE(jm_getAccessibleRowCount, clsAJTInfo, "getAccessibleRowCount", "()I");
    jint javaRowsCount = JNFCallIntMethod(env, [self accessibleContext], jm_getAccessibleRowCount);
    return (int)javaRowsCount;
}

- (int)accessibleColCount {
    JNIEnv *env = [ThreadUtilities getJNIEnv];
    jclass clsAJT = (*env)->GetObjectClass(env, [self accessibleContext]);
    JNFClassInfo clsAJTInfo;
    clsAJTInfo.name = "javax.swing.JTable$AccessibleJTable";
    clsAJTInfo.cls = clsAJT;
    JNF_MEMBER_CACHE(jm_getAccessibleColumnCount, clsAJTInfo, "getAccessibleColumnCount", "()I");
    jint javaColsCount = JNFCallIntMethod(env, [self accessibleContext], jm_getAccessibleColumnCount);
    return (int)javaColsCount;
}

@end
