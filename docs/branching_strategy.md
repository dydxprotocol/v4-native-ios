# Project Branching and Hotfix Strategy Guide

This document outlines the branching strategy our project adopts, accommodating regular development, releases, and hotfixes. Following this strategy ensures an organized development process and stable production code.

## 1. General Branching Strategy

Our branching method involves several branches serving distinct roles in the code changes' lifecycle. Here's what our branch structure looks like:

### 1.1 `main` Branch

- Stores official release history.
- Every commit represents a production-ready state.

### 1.2 `develop` Branch

- Serves as a pre-production staging area.
- It's where code merges before it's ready for production.

### 1.3 Feature Branches

- Branch off from `develop` and integrate back into it when the feature is complete.
- Used for single feature development or improvements.

### 1.4 Release Branches

- Branch off from `develop` when it reaches a production-ready state.
- These branches are long-lived and serve for creating a release history, enabling referencing or hotfixing in the future.

**Workflow Summary:**

1. Regular work (features and non-critical fixes) is done in feature branches.
2. These are merged into `develop` upon completion.
3. When `develop` is ready for production, a new `release/...` branch is created.
4. Release branches may receive minor polishing and bug fixing.
5. When finalized, the `release` branch merges into `main` and is tagged with a version number if commits were made in step 4. The release branch also merges back any changes into `develop`.

## 2. Hotfix Strategy

Hotfixes address critical production issues, requiring immediate resolution outside the regular cycle.

### 2.1 Hotfix Branches

- These are created from the appropriate `release/...` branch, providing a controlled area to fix the issue.
- These are no different than a normal release branch aside from being based on a previous `release/...` branch instead of `main`
- After testing, hotfixes merge into both `main` and `develop` to update the production version and include fixes in the upcoming releases.

### Hotfix Workflow

Let's say that an issue needing a hotfix was discovered in released version `1.0.1` 

1. Locate the `release/1.0.1` branch.
2. Branch off `release/1.0.1` into a new hotfix `release/1.0.2` branch.
    ```sh
    git checkout release/1.0.1
    git pull
    git checkout -b release/1.0.2
    ```
3. Implement and test the fix rigorously on the hotfix branch.
4. If hotfix release version is **greater** than latest main version tag, follow workflow A. Otherwise follow workflow B.

#### **Workflow A**
1. merge the hotfix branch into `main`
    ```sh
    git checkout main
    git merge release/1.0.2
    ```
2. Tag this new release merge commit on `main` with an updated version number.
    ```sh
    git tag -a v(new_version) -m "v1.0.2"
    git push origin --tags
    ```
3. Merge the hotfix into `develop` to ensure it's part of future releases.
    ```sh
    git checkout develop
    git merge release/1.0.2
    ```

#### **Workflow B**
1.  Branch off `release/<LATEST>` into another hotfix `release/<LATEST_PATCH_INCREMENTED>` branch. 
    ```sh
    # e.g. LATEST is 2.1.1
    git checkout release/<LATEST> 
    git pull
    # LATEST_PATCH_INCREMENTED would then be 2.1.2
    git checkout -b release/<LATEST_PATCH_INCREMENTED> 
    ```
2. Merge the `release/1.0.2` hotfix changes into `release/<LATEST_PATCH_INCREMENTED>`
    ```sh
    git checkout release/<LATEST_PATCH_INCREMENTED>
    git merge release/1.0.2
    ```
3. merge the `release/<LATEST_PATCH_INCREMENTED>` hotfix branch into `main`
    ```sh
    git checkout main
    git merge release/<LATEST_PATCH_INCREMENTED>
    ```
4. Tag this new release merge commit on `main` with an updated version number.
    ```sh
    git tag -a v(new_version) -m "v<LATEST_PATCH_INCREMENTED>"
    git push origin --tags
    ```
5. Merge the hotfix into `develop` to ensure it's part of future releases.
    ```sh
    git checkout develop
    git merge release/<LATEST_PATCH_INCREMENTED>
    ``` 
    
    

## 3. Example
The following branching history visualization depicts a project which:
1. Released 1.0.0 based off the latest develop at the time
2. Released 1.0.1 based off 1.0.0 for a hotfix
3. Released 1.1.0 based off the latest develop at the time
<img src="https://mermaid.ink/img/pako:eNqVU8tqwzAQ_BWxEEggJNHVt0JKe-9VUDbS2hKxLCPLoSXk3ytXdvqwYxKdhGZnRzMrnUE6RZBBYcKLx1qLisUlnbUmMKMyAXyz2-wEJODgsZKaCVB0otLVw_lvQtq_4wx2-NfPU0nY0DZpJZYmeXRtmMQmOrJlg5bY6_PTfnVVHnoMt73FlgNjsWCWfEF3qqqRkkVTpaOJPixgEcmnP5HOGZ2Ih98XAZtJn9iydqVp9Fa7kJuPcV6j-Y7N8AeM82_jrHfO7x0Pu944H7v5AYs5UN98aXzmpfGZmes-Zk2oVg_Mn_fzTzF0CgBriFWRouIPPHc0AUGTJQFdmUJ_7AQusQ7b4N4-KwlZ8C2toa0VBtobLDxayHIsG7p8AQ6yNNY?type=png)](https://mermaid.live/edit#pako:eNqVU8tqwzAQ_BWxEEggJNHVt0JKe-9VUDbS2hKxLCPLoSXk3ytXdvqwYxKdhGZnRzMrnUE6RZBBYcKLx1qLisUlnbUmMKMyAXyz2-wEJODgsZKaCVB0otLVw_lvQtq_4wx2-NfPU0nY0DZpJZYmeXRtmMQmOrJlg5bY6_PTfnVVHnoMt73FlgNjsWCWfEF3qqqRkkVTpaOJPixgEcmnP5HOGZ2Ih98XAZtJn9iydqVp9Fa7kJuPcV6j-Y7N8AeM82_jrHfO7x0Pu944H7v5AYs5UN98aXzmpfGZmes-Zk2oVg_Mn_fzTzF0CgBriFWRouIPPHc0AUGTJQFdmUJ_7AQusQ7b4N4-KwlZ8C2toa0VBtobLDxayHIsG7p8AQ6yNNY">

This example can be recreated with [mermaid.live's tool](https://mermaid.live/) and the following code.
```
gitGraph
    commit id:"1.0.0"
    branch "develop"
    commit id:"commit_a"
    commit id:"commit_b"
    branch release/1.0.0
    checkout release/1.0.0
    commit id:"commit_b (same HEAD)"
    checkout develop
    commit id:"commit_c"
    commit id:"commit_d"
    checkout main
    merge release/1.0.0 tag:"v1.0.0"
    checkout release/1.0.0
    branch release/1.0.1
    commit id:"commit_b (same HEAD) "
    commit id:"commit_e (polish)"
    checkout "develop"
    merge release/1.0.1
    checkout main
    merge release/1.0.1 tag: "v1.0.1"
    checkout develop
    commit id: "commit_f"
    commit id: "commit_g"
    commit id: "commit_h"
    branch release/1.1.0
    checkout release/1.1.0
    commit id:"commit_h (same head)"
    checkout main
    merge release/1.1.0 tag: "v1.1.0"
```

## 4. Release Management

The presence of release branches adds an extra layer of stability, as they remain available for any future needs for referencing or hotfixing that specific release.

## 5. Conclusion

This branching strategy and hotfix procedure ensure a robust framework for continuous development, stable production releases, and efficient deployment of critical fixes. It emphasizes the importance of team collaboration, communication, and a structured approach to managing code lifecycles.

