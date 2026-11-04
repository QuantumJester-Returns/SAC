# Phone-Only Development Workflow

The project owner is currently working entirely from an Android phone. This changes the collaboration workflow, not the intended scope or final platform.

## Work that can be done through GitHub

- Create and review C++ source files.
- Maintain Unreal configuration and project documentation.
- Create original text-based source assets such as OBJ meshes.
- Track asset provenance, licences, and import instructions.
- Review diffs and milestones from the GitHub repository.

## Work that requires an Unreal build environment

- Generate and save Unreal-native `.uasset` and `.umap` files.
- Compile the C++ project against the selected Unreal Engine release.
- Run the editor and validate rendering.
- Package, sign, and install Android APK builds.

These tasks require a compatible Unreal Engine installation and Android toolchain. A phone-only GitHub workflow cannot honestly claim that an Unreal project has compiled or that an APK has been produced.

## Future build runner

When the source foundation is ready, evaluate a free or already-available remote build machine. Unreal Engine Android packaging is demanding and requires a compatible engine/toolchain installation; ordinary hosted CI runners should not be assumed to have it. A self-hosted PC runner or a suitable remote PC may be necessary.

## Android signing

Create the persistent Android release keystore only in a secure environment with a secure backup plan. Never generate, upload, or commit it casually. Do not distribute the first signed APK until the key is safely backed up and verified.
