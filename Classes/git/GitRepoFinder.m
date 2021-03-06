//
//  GitRepoFinder.m
//  GitX
//
//  Created by Rowan James on 13/11/2012.
//
//

#import "GitRepoFinder.h"

@implementation GitRepoFinder

+ (NSURL*)workDirForURL:(NSURL*)fileURL;
{
	GTRepository* repo = [[GTRepository alloc] initWithURL:fileURL
													 error:nil];
	NSURL* result = repo.fileURL;
	return result;
}

+ (NSURL *)gitDirForURL:(NSURL *)fileURL
{
	if (!fileURL.isFileURL)
	{
		return nil;
	}
	NSMutableData* repoPathBuffer = [NSMutableData dataWithLength:GIT_PATH_MAX];
	
	int gitResult = git_repository_discover(repoPathBuffer.mutableBytes,
											repoPathBuffer.length,
											[fileURL.path UTF8String],
											GIT_REPOSITORY_OPEN_CROSS_FS,
											nil);
	
	if (gitResult == GIT_OK)
	{
		NSString* repoPath = [NSString stringWithUTF8String:repoPathBuffer.bytes];
		BOOL isDirectory;
		if ([[NSFileManager defaultManager] fileExistsAtPath:repoPath
												 isDirectory:&isDirectory] && isDirectory)
		{
			NSURL* result = [NSURL fileURLWithPath:repoPath
									   isDirectory:isDirectory];
			return result;
		}
	}
	return nil;
}

+ (NSURL*) fileURLForURL:(NSURL *)inputURL
{
	NSURL* gitDir = [GitRepoFinder gitDirForURL:inputURL];
	if (!gitDir)
	{
		return nil; // not a Git directory at all
	}
	NSURL* workDir = [GitRepoFinder workDirForURL:inputURL];
	if (workDir)
	{
		return workDir; // root of this working copy or deepest submodule
	}
	return gitDir; // bare repo
}

@end
