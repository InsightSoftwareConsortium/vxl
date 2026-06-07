# VXL fork for Insight Toolkit (ITK)

This project is a fork of the VXL source hosted at https://github.com/vxl/vxl.git.

This project contains the changes required to vendor VXL's VNL libraries into
ITK. ITK consumes a filtered subtree of this fork (primarily `core/vnl`,
`core/vxl_config.h.in`, `vcl`, and the `v3p/netlib` BLAS/LAPACK sources) through
`Modules/ThirdParty/VNL/UpdateFromUpstream.sh`. The overlay carries the
ITK-relevant modernization and build patches that have not yet landed in
upstream VXL.

# What is the branch naming convention?

Each fork branch is named with the pattern `for/itk-vxl-VERSION-SHA{7}`

where:
- `VERSION` is the upstream VXL release the ITK overlay is built on (e.g.
  `3.5.0`), or `master` when the overlay is based on the upstream `master` tip
  rather than a tagged release.
- `SHA{7}` is the 7-character commit hash of the upstream base commit.

For example, `for/itk-vxl-master-30cfa52` carries the ITK overlay on top of
upstream `master` at commit `30cfa52`.

The default branch of this fork is `welcome`, an orphan branch holding only this
document. ITK pins a specific commit of a `for/itk-vxl-*` branch via the `tag`
variable in `Modules/ThirdParty/VNL/UpdateFromUpstream.sh`.

Additional documentation on developing ITK:
https://docs.itk.org/en/latest/contributing/index.html

See also ITK's [Third-Party Fork Conventions](https://github.com/InsightSoftwareConsortium/ITK/blob/main/Documentation/Maintenance/ThirdPartyForkConventions.md).

# Workflow for Updating

## Setup repositories

1. Clone (or reuse) the fork and ensure the tree is clean:

```
git clone https://github.com/InsightSoftwareConsortium/vxl.git
cd vxl
```

2. Wire the upstream remote:

```
git remote add upstream https://github.com/vxl/vxl.git
```

3. Fetch:

```
git fetch origin
git fetch upstream
```

## Create a new branch following the convention

4. Choose the upstream base. VXL has no recent release cadence, so the overlay
   is normally built on the upstream `master` tip. Derive the base SHA and the
   branch name:

```
git fetch upstream master
SHA=$(git rev-parse --short=7 upstream/master)
echo "SHA [${SHA}]"

# Use the upstream release version when basing on a tag; use "master" otherwise.
ITK_VXL_TARGET_VERSION=master
NEW_BRANCH="for/itk-vxl-${ITK_VXL_TARGET_VERSION}-${SHA}"
echo "NEW_BRANCH [${NEW_BRANCH}]"

git switch -c "${NEW_BRANCH}" upstream/master
```

5. Re-integrate the ITK overlay. The overlay is the set of VXL changes ITK needs
   that are not yet upstream. These are tracked as open VXL pull requests; merge
   each with a `--no-ff` merge commit that records its PR number so the topology
   stays auditable:

```
# For every open ITK-relevant VXL PR (head branch fetched into a remote):
git merge --no-ff <remote>/<pr-head-branch> \
    -m "Merge vxl/vxl#<N>: <pr title>"
```

   As each PR lands upstream, drop it from the overlay on the next update; the
   goal is to shrink the overlay to empty over time.

## Pin the new branch in ITK

6. Push the new branch and update ITK:

```
git push origin "${NEW_BRANCH}"
```

   In ITK, set both the `repo` and `tag` variables in
   `Modules/ThirdParty/VNL/UpdateFromUpstream.sh`:

```
readonly repo="https://github.com/InsightSoftwareConsortium/vxl.git"
readonly tag="for/itk-vxl-master-${SHA}"
```

   Then run `Modules/ThirdParty/VNL/UpdateFromUpstream.sh` from a clean ITK
   checkout to refresh the vendored subtree, and commit the result following
   ITK's third-party update conventions.
