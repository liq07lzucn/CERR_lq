function [CI] = dicomrt_CIcal(inputdose,dose_xmesh,dose_ymesh,dose_zmesh,norm,dref,VOI,voi2use)
% dicomrt_CIcal(inputdose,dose_xmesh,dose_ymesh,dose_zmesh,norm,dref,VOI,voi2use)
%
% Calculate Conformity index for a given 3D dose distribution
%
% inputdose is the input 3D dose (e.g. RTPLAN or MC generated)
% dose_xmesh,dose_ymesh,dose_zmesh are x-y-z coordinates of the center of the dose-voxel 
% norm is the dose normalization level
% norm =0 (default) no normalization is carried out
%      ~=0 doses are normalized to the provided "norm" value (100%)
% dref is the dose level (relative to norm) that will be used for the calculation of the CI 
% VOI is a cell array which contain the patients VOIs as read by dicomrt_loadvoi
% voi2use is a vector pointing to the number of VOIs to be used ot the analysis and for the display.
%
% Radiation conformity index (RCI - Knoos et al IJROBP 42 1169-1176, 1998) or more simply conformity index (CI -
% IRCU 50 and 62) is defined as the ratio between the volume of the target (Vt) and a volume Vdref.
% Vdref can be the any volume defined by a certain isodose surface "ref" considered clinically relevant 
% (e.g. 95% of the prescribed dose).
% 
% CI=Vt/Vdref
%
% CI is then an increasing function with conformity, reaching unity for a perfect conformal treatment.
% ICRU also specify that the target (or PTV) must be fully enclosed in the Vdref. 
% This is not checked here and this also the limitation of the definition of Konoos etal.
% Another conformity index was defined by van't Riet etal IJROBP (1997) Vol.37 No.3 pp.731-736.
% This function is implemented in dicomrt_CNcal and it not affected by the problem above.
% 
% Example:
%
% [volume_VOI,volume_threshold,conformity_index]=dicomrt_CIcal(A,dose_xmesh,dose_ymesh,dose_zmesh,...
%    105,60,demo_voi,9);
%
% calculates the CI for the dose matrix A and returns it in conformity_index.
% The volumes ot the VOI # 9 and the volume of the isodose volume for 105% (60 Gy = 100%) are also 
% returned into volume_VOI and volume_threshold respectively
% The above call is equavilent to the following:
%
% [volume_VOI,volume_threshold,conformity_index]=dicomrt_CIcal(A,dose_xmesh,dose_ymesh,dose_zmesh,...
%    63,0,demo_voi,9);
%
% See also dicomrt_CNcal, dicomrt_mask
%
% Copyright (C) 2002 Emiliano Spezi (emiliano.spezi@physics.org) 


% Check case and set-up some parameters and variables
[dose_temp,type_dose,label]=dicomrt_checkinput(inputdose,1);
[dose]=dicomrt_varfilter(dose_temp);

% Check normalization
if norm~=0
    dose=dose./norm.*100;
end

% mask dose matrix using VOI
[mask_VOI,Vt,mask4VOI,vbin]=dicomrt_mask(VOI,dose_temp,dose_xmesh,dose_ymesh,dose_zmesh,voi2use,'nan','n');

% Calculate volume covered by "dref" dose
Vdref=0;
for kk=1:size(dose,3)
    [ii,jj]=find(dose(:,:,kk)>=dref);
    if isempty(ii)~=1
        Vdref=Vdref+length(ii)*vbin(kk);
    end
end

% Calculate CI
CI=Vt/Vdref;